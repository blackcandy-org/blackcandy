# frozen_string_literal: true

module GlobalSetting
  extend ActiveSupport::Concern

  included do
    AVAILABLE_SETTINGS = []
    FORCE_STRING_SETTINGS = []

    singleton_class.prepend(PrependClassMethods)
  end

  class_methods do
    def fields_force_to_string(*keys)
      FORCE_STRING_SETTINGS.push(*keys)
      singleton_class.prepend(ForceStringMethods)
    end
  end

  module ForceStringMethods
    def self.prepended(base)
      # Overwrite setting read method let method force return to a string
      FORCE_STRING_SETTINGS.each do |key|
        define_method(key) { super().to_s }
      end
    end
  end

  module PrependClassMethods
    # Overwrite field method on setting to track available settings
    def field(key, **opts)
      AVAILABLE_SETTINGS.push(key)
      super(key, **opts)
    end
  end
end
