require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

require_relative "../lib/black_candy/configurable"
require_relative "../lib/black_candy/errors"
require_relative "../lib/black_candy/version"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlackCandy
  SUPPORTED_DATABASE_ADAPTERS = %w[sqlite postgresql]

  include BlackCandy::Configurable

  has_config :db_url
  has_config :media_path
  has_config :db_adapter, default: "sqlite"
  has_config :nginx_sendfile, default: false
  has_config :force_ssl, default: false
  has_config :demo_mode, default: false

  config_validate :db_adapter do |value|
    unless SUPPORTED_DATABASE_ADAPTERS.include?(value)
      raise_config_validation_error "Unsupported database adapter."
    end

    if value == "postgresql" && ENV["RAILS_ENV"] == "production" && config.db_url.blank?
      raise_config_validation_error "DB_URL is required if database adapter is postgresql"
    end
  end

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.active_support.cache_format_version = 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks black_candy puma])

    config.exceptions_app = routes

    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    config.solid_queue.silence_polling = true
    config.solid_queue.preserve_finished_jobs = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
