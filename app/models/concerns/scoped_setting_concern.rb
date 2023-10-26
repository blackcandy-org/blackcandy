# frozen_string_literal: true

module ScopedSettingConcern
  extend ActiveSupport::Concern

  included do
    const_set(:AVAILABLE_SETTINGS, [])
  end

  class_methods do
    def has_setting(setting, type: :string, default: nil)
      self::AVAILABLE_SETTINGS.push(setting)

      store :settings, accessors: setting

      define_method(setting) do
        setting_value = ScopedSettingConcern.convert_setting_value(type, super())

        setting_value || default
      end
    end
  end

  def self.convert_setting_value(type, value)
    return value if value.nil?

    case type
    when :boolean
      ["true", "1", 1, true].include?(value)
    when :integer
      value.to_i
    else
      value.to_s
    end
  end
end
