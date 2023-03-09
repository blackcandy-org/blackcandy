# frozen_string_literal: true

module Sortable
  extend ActiveSupport::Concern

  included do
    const_set(:VALID_SORTS, [])
  end

  class_methods do
    def sort_by(*attributes)
      attributes.each do |attr|
        scope "sort_by_#{attr}", ->(direction) { order(attr => direction) }
        self::VALID_SORTS.push(attr.to_s)
      end
    end

    def sort_by_associations(associations)
      associations = Hash(associations)

      associations.each do |name, attrs|
        Array(attrs).each do |attr|
          sort_name = "#{name}_#{attr}"
          scope "sort_by_#{sort_name}", ->(direction) {
            joins(name).order("#{name}.#{attr}" => direction)
          }

          self::VALID_SORTS.push(sort_name.to_s)
        end
      end
    end

    def sort_records(sort_name = "", sort_direction = "")
      sort_direction = (sort_direction.to_s == "desc") ? "desc" : "asc"
      return public_send("sort_by_#{sort_name}", sort_direction) if self::VALID_SORTS.include?(sort_name.to_s)

      default_sort_name, default_sort_direction = default_sort
      public_send("sort_by_#{default_sort_name}", default_sort_direction)
    end

    def default_sort
      const_defined?(:DEFAULT_SORT) ? self::DEFAULT_SORT : [self::VALID_SORTS.first, "asc"]
    end

    def sort_options
      {sorts: self::VALID_SORTS, default: default_sort}
    end
  end
end
