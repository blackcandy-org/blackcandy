# frozen_string_literal: true

module GlobalSetting
  extend ActiveSupport::Concern

  included do
    # Ensures only one Settings row is created
    validates :singleton_guard, inclusion: {in: [0]}
    const_set(:AVAILABLE_SETTINGS, [])
  end

  class_methods do
    delegate :update, to: :instance

    def instance
      first_or_create!(singleton_guard: 0)
    end

    def has_settings(*settings)
      self::AVAILABLE_SETTINGS.push(*settings)

      store_accessor :values, *settings

      settings.each do |setting|
        define_singleton_method(setting) do
          setting_value = instance.send(setting)
          setting_value || ENV[setting.to_s.upcase]
        end
      end
    end

    def has_setting(setting, type: :string, default: nil, available_options: nil)
      self::AVAILABLE_SETTINGS.push(setting)

      store_accessor :values, setting

      validates setting, inclusion: {in: available_options}, allow_nil: true if available_options

      define_method("#{setting}=") do |value|
        setting_value = ScopedSetting.convert_setting_value(type, value)
        super(setting_value)
      end

      define_method(setting) do
        ScopedSetting.convert_setting_value(type, super())
      end

      define_singleton_method(setting) do
        setting_value = instance.send(setting)
        setting_value || default
      end
    end
  end
end
