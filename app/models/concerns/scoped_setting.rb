# frozen_string_literal: true

module ScopedSetting
  extend ActiveSupport::Concern

  included do
    AVAILABLE_SETTINGS = []
  end

  class_methods do
    def has_setting(setting, default: nil, available_options: nil)
      AVAILABLE_SETTINGS.push(setting)

      store_accessor :settings, setting

      if available_options
        validates_inclusion_of setting, in: available_options
      end

      define_method(setting) do
        super() || default
      end
    end
  end
end
