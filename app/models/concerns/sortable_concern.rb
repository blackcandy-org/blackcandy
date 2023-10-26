# frozen_string_literal: true

module SortableConcern
  extend ActiveSupport::Concern

  included do
    const_set(:SORT_OPTION, SortOption.new)
  end

  class_methods do
    def sort_by(*attributes)
      attributes.each do |attr|
        scope "sort_by_#{attr}", ->(direction) { order(attr => direction) }
        self::SORT_OPTION.push(attr.to_s)
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

          self::SORT_OPTION.push(sort_name.to_s)
        end
      end
    end

    def sort_records(sort_name = "", sort_direction = "")
      sort_value = SortValue.new(sort_name, sort_direction)
      return public_send("sort_by_#{sort_value.name}", sort_value.direction) if self::SORT_OPTION.include?(sort_value.name.to_s)

      default_sort = self::SORT_OPTION.default
      public_send("sort_by_#{default_sort.name}", default_sort.direction)
    end

    def default_sort(sort_name, sort_direction)
      self::SORT_OPTION.set_default(sort_name, sort_direction)
    end
  end
end
