# frozen_string_literal: true

module BlackCandy
  class Config
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

    has_config :db_url
    has_config :media_path
    has_config :db_adapter, default: "sqlite"
    has_config :nginx_sendfile, default: false
    has_config :force_ssl, default: false
    has_config :demo_mode, default: false

    validate :db_adapter do |value|
      unless SUPPORTED_DATABASE_ADAPTERS.include?(value)
        raise_validation_error "Unsupported database adapter."
      end

      if value == "postgresql" && ENV["RAILS_ENV"] == "production" && db_url.blank?
        raise_validation_error "DB_URL is required if database adapter is postgresql"
      end
    end
  end
end
