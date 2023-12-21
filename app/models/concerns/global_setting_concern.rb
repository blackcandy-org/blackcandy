# frozen_string_literal: true

module GlobalSettingConcern
  extend ActiveSupport::Concern

  included do
    # Ensures only one Settings row is created
    validates :singleton_guard, inclusion: {in: [0]}
    const_set(:AVAILABLE_SETTINGS, [])
  end

  class_methods do
    delegate :update, to: :instance

    def instance
      Current.setting ||= first_or_create!(singleton_guard: 0)
    end

    def has_setting(setting, type: :string, default: nil)
      self::AVAILABLE_SETTINGS.push(setting)

      store :values, accessors: setting

      define_method("#{setting}=") do |value|
        setting_value = ScopedSettingConcern.convert_setting_value(type, value)
        super(setting_value)
      end

      define_method(setting) do
        ScopedSettingConcern.convert_setting_value(type, super())
      end

      define_singleton_method(setting) do
        setting_value = instance.send(setting)
        default_value = default.is_a?(Proc) ? default.call : default

        setting_value || default_value
      end

      if type == :boolean
        alias_method "#{setting}?", setting
        singleton_class.send(:alias_method, "#{setting}?", setting)
      end
    end
  end
end
