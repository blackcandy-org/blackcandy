# frozen_string_literal: true

module GlobalSetting
  extend ActiveSupport::Concern

  included do
    # Ensures only one Settings row is created
    validates :singleton_guard, inclusion: { in: [0] }
  end

  class_methods do
    delegate :update, to: :instance

    def instance
      first_or_create!(singleton_guard: 0)
    end

    def has_settings(*settings)
      const_set(:AVAILABLE_SETTINGS, settings)

      store_accessor :values, *settings

      settings.each do |setting|
        define_singleton_method(setting) do
          instance.send(setting) || ENV[setting.to_s.upcase]
        end
      end
    end
  end
end
