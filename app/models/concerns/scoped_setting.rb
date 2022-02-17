# frozen_string_literal: true

module ScopedSetting
  extend ActiveSupport::Concern

  included do
    const_set(:AVAILABLE_SETTINGS, [])
  end

  class_methods do
    def has_setting(setting, type: :string, default: nil, available_options: nil)
      self::AVAILABLE_SETTINGS.push(setting)

      store_accessor :settings, setting

      validates setting, inclusion: {in: available_options}, allow_nil: true if available_options

      define_method(setting) do
        setting_value = ScopedSetting.convert_setting_value(type, super())

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
    when :float
      value.to_f
    else
      value
    end
  end
end
