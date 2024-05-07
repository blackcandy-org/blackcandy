# frozen_string_literal: true

class FilterSortPresenter
  def initialize(params)
    @params = params
  end

  def has_filter?
    params[:filter].present?
  end

  def filter_value(key)
    params[:filter].fetch(key, nil)
  end

  def sort_value
    params[:sort]
  end

  def sort_direction_value
    params[:sort_direction]
  end

  def params(other_hash = {})
    filter_params = @params[:filter].presence || {}
    filter_params = filter_params.merge(other_hash.delete(:filter) || {})
    new_params = @params.merge(other_hash).merge(filter: filter_params)

    new_params.slice(:filter, :sort, :sort_direction).permit!
  end
end
