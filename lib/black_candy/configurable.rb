# frozen_string_literal: true

module BlackCandy
  module Configurable
    def self.included(base)
      base.instance_variable_set(:@config, Config.new)
      base.extend ClassMethods
    end

    class Config
      class ValidationError < StandardError; end

      attr_accessor :validate_blocks

      def initialize
        @validate_blocks = {}
      end
    end

    module ClassMethods
      attr_reader :config

      def has_config(config_name, default: nil)
        @config.define_singleton_method(config_name) do
          config_value = instance_variable_get("@#{config_name}")
          env_value = ENV[config_name.to_s.upcase]
          default_value = default.is_a?(Proc) ? default.call : default

          return default_value if (env_value.nil? || env_value.empty?) && config_value.nil?

          converted_env_value = case default_value.class.name
          when "TrueClass", "FalseClass"
            ["true", "yes"].include?(env_value&.downcase)
          when "Integer"
            env_value.to_i
          else
            env_value.to_s
          end

          config_value ||= converted_env_value

          validate_block = @validate_blocks&.fetch(config_name, nil)
          validate_block.call(config_value) if validate_block.respond_to?(:call)

          config_value
        end

        @config.define_singleton_method("#{config_name}=") do |value|
          instance_variable_set("@#{config_name}", value)
        end

        if [true, false].include?(default)
          @config.singleton_class.send(:alias_method, "#{config_name}?", config_name)
        end
      end

      def config_validate(config_name, &block)
        @config.validate_blocks[config_name] = block
      end

      def configure
        yield @config
      end

      def raise_config_validation_error(message)
        raise Config::ValidationError.new(message)
      end
    end
  end
end
