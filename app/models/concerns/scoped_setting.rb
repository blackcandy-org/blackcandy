# frozen_string_literal: true

module ScopedSetting
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :thing
    AVAILABLE_SETTINGS = []
  end

  class_methods do
    def scoped_field(name, default: nil, available_options: nil)
      AVAILABLE_SETTINGS.push(name)

      define_method(name) do
        setting = settings.where(var: name).take || settings.new(var: name, value: default)
        setting.value
      end

      define_method("#{name}=") do |value|
        setting = settings.where(var: name).take || settings.new(var: name)

        if available_options.blank? || available_options&.include?(value)
          setting.value = value
          setting.save!
        end

        value
      end
    end
  end
end
