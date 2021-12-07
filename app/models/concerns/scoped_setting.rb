# frozen_string_literal: true

module ScopedSetting
  extend ActiveSupport::Concern

  included do
    const_set(:AVAILABLE_SETTINGS, [])
  end

  class_methods do
    def has_setting(setting, default: nil, available_options: nil)
      self::AVAILABLE_SETTINGS.push(setting)

      store_accessor :settings, setting

      validates setting, inclusion: {in: available_options}, allow_nil: true if available_options

      define_method(setting) do
        setting_value = super()
        !setting_value.nil? ? setting_value : default
      end
    end
  end
end
