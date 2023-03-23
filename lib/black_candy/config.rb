# frozen_string_literal: true

module BlackCandy
  class Config
    # Accroding to the documentation, a good rule of thumb is that your puma threads + sidekiq concurrency should never be greater than 5
    MAX_THREADS_FOR_EMBEDDED_SIDEKIQ = 5
    SUPPORTED_DATABASE_ADAPTERS = %w[sqlite postgresql]

    class ValidationError < StandardError; end

    class << self
      private

      def has_config(config_name, default: nil)
        define_singleton_method(config_name) do
          env_value = ENV[config_name.to_s.upcase]
          default_value = default.is_a?(Proc) ? default.call : default

          return default_value if env_value.nil? || env_value.empty?

          config_value = case default_value.class.name
          when "TrueClass", "FalseClass"
            ["true", "yes"].include?(env_value&.downcase)
          when "Integer"
            env_value.to_i
          else
            env_value.to_s
          end

          validate_block = @validate_blocks&.fetch(config_name, nil)
          validate_block.call(config_value) if validate_block.respond_to?(:call)

          config_value
        end

        if [true, false].include?(default)
          singleton_class.send(:alias_method, "#{config_name}?", config_name)
        end
      end

      def validate(config_name, &block)
        @validate_blocks ||= {}
        @validate_blocks[config_name] = block
      end

      def raise_validation_error(message)
        raise ValidationError.new(message)
      end
    end

    has_config :redis_url
    has_config :redis_cache_url, default: proc { redis_url }
    has_config :redis_sidekiq_url, default: proc { redis_url }
    has_config :redis_cable_url, default: proc { redis_url }
    has_config :database_url
    has_config :media_path
    has_config :database_adapter, default: "sqlite"
    has_config :nginx_sendfile, default: false
    has_config :embedded_sidekiq, default: false
    has_config :embedded_sidekiq_concurrency, default: 2
    has_config :force_ssl, default: false
    has_config :demo_mode, default: false

    # Accroding to the documentation, we should keep embedded sidekiq concurrency very low, i.e. 1-2
    validate :embedded_sidekiq_concurrency do |value|
      if value > 2
        raise_validation_error "The concurrency of embedded sidekiq is too high."
      end
    end

    validate :database_adapter do |value|
      unless SUPPORTED_DATABASE_ADAPTERS.include?(value)
        raise_validation_error "Unsupported database adapter."
      end

      if value == "postgresql" && database_url.blank?
        raise_validation_error "DATABASE_URL is required if database adapter is postgresql"
      end
    end

    def self.puma_max_threads_count
      embedded_sidekiq ? (MAX_THREADS_FOR_EMBEDDED_SIDEKIQ - embedded_sidekiq_concurrency) : ENV.fetch("RAILS_MAX_THREADS", 5)
    end

    def self.puma_min_threads_count
      embedded_sidekiq ? (MAX_THREADS_FOR_EMBEDDED_SIDEKIQ - embedded_sidekiq_concurrency) : ENV.fetch("RAILS_MIN_THREADS") { puma_max_threads_count }
    end
  end
end
