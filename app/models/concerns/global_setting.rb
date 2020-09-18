# frozen_string_literal: true

module GlobalSetting
  extend ActiveSupport::Concern

  included do
    AVAILABLE_SETTINGS = []

    # Ensures only one Settings row is created
    validates_inclusion_of :singleton_guard, in: [0]
  end

  class_methods do
    def instance
      first_or_create!(singleton_guard: 0)
    end

    def update(attributes)
      instance.update(attributes)
    end

    def has_settings(*settings)
      AVAILABLE_SETTINGS.push(*settings)

      store_accessor :values, *settings

      settings.each do |setting|
        define_singleton_method(setting) do
          instance.send(setting) || ENV[setting.to_s.upcase]
        end
      end
    end
  end
end
