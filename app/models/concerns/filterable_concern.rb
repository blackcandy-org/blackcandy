# frozen_string_literal: true

module FilterableConcern
  extend ActiveSupport::Concern

  included do
    const_set(:VALID_FILTERS, [])
  end

  class_methods do
    def filter_by(*attributes)
      attributes.each do |attr|
        scope "filter_by_#{attr}", ->(value) { where(attr => value) }
        self::VALID_FILTERS.push(attr.to_s)
      end
    end

    def filter_by_associations(associations)
      associations = Hash(associations)

      associations.each do |name, attrs|
        Array(attrs).each do |attr|
          filter_name = "#{name}_#{attr}"
          scope "filter_by_#{filter_name}", ->(value) {
            joins(name.to_sym).where(name => {attr => value})
          }

          self::VALID_FILTERS.push(filter_name.to_s)
        end
      end
    end

    def filter_records(filtering_params)
      results = where(nil)
      return results if filtering_params.blank?

      filtering_params.each do |key, value|
        results = results.public_send("filter_by_#{key}", value) if self::VALID_FILTERS.include?(key.to_s) && value.present?
      end

      results
    end
  end
end
