# frozen_string_literal: true

module ScopedSetting
  extend ActiveSupport::Concern

  class_methods do
    def has_setting(setting, default: nil, available_options: nil)
      const_set(:AVAILABLE_SETTINGS, [setting])

      store_accessor :settings, setting

      validates setting, inclusion: {in: available_options} if available_options

      define_method(setting) do
        super() || default
      end
    end
  end
end
