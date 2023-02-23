# frozen_string_literal: true

module Orderable
  extend ActiveSupport::Concern

  included do
    before_action :get_order_selection, only: [:index]
    const_set(:VALID_ORDER_VALUES, [])
  end

  class_methods do
    def order_by(*args)
      self::VALID_ORDER_VALUES.push(*args.map(&:to_s))
    end
  end

  private

  def order_condition
    direction = (params[:order_direction] == "desc") ? "desc" : "asc"

    return {params[:order] => direction} if self.class::VALID_ORDER_VALUES.include?(params[:order])
    return {default_order[:value] => default_order[:direction]} if default_order.present?
  end

  def default_order
    default_value = self.class::VALID_ORDER_VALUES.first
    return unless default_value.present?

    {value: default_value, direction: "asc"}
  end

  def get_order_selection
    @order_selection = {values: self.class::VALID_ORDER_VALUES, default: default_order}
  end
end
