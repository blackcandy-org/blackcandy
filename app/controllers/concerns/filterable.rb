# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  included do
    const_set(:VALID_FILTERS_PARAMS, [])
  end

  class_methods do
    def filter_by(*args)
      self::VALID_FILTERS_PARAMS.push(*args.map(&:to_s))
    end
  end

  private

  def filter_conditions
    filter_params = []

    filters = self.class::VALID_FILTERS_PARAMS.map do |filter|
      next unless params[filter].present?
      filter_params.push(params[filter])

      "#{filter} = ?"
    end.reject(&:blank?)

    [filters.join(" AND "), *filter_params] unless filters.blank?
  end
end
