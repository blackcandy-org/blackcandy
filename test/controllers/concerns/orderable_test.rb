# frozen_string_literal: true

require "test_helper"

class NotImplementedDummyOrderableController < ApplicationController
  include Orderable

  def index
    render json: order_condition
  end
end

class DummyOrderableController < ApplicationController
  include Orderable

  order_by :name, :email, :created_at

  def index
    render json: order_condition
  end
end

class OverrideDummyOrderableController < ApplicationController
  include Orderable

  def index
    render json: order_condition
  end

  def default_order
    {value: "new_name", direction: "desc"}
  end
end

class OrderableTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get "/not_implemented_dummy_order", to: "not_implemented_dummy_orderable#index"
      get "/dummy_order", to: "dummy_orderable#index"
      get "/override_dummy_order", to: "override_dummy_orderable#index"
    end

    login
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "should raise error when order_values is not defined" do
    get "/not_implemented_dummy_order"
    assert_match "null", @response.body
  end

  test "should get default order contidions" do
    get "/dummy_order"
    assert_match "{\"name\":\"asc\"}", @response.body
  end

  test "should get order contidions from parmas" do
    get "/dummy_order", params: {order: "email"}
    assert_match "{\"email\":\"asc\"}", @response.body

    get "/dummy_order", params: {order: "created_at", order_direction: "desc"}
    assert_match "{\"created_at\":\"desc\"}", @response.body
  end

  test "should get default order contidions when order parmas is not in order_values" do
    get "/dummy_order", params: {order: "foo"}
    assert_match "{\"name\":\"asc\"}", @response.body
  end

  test "should can override default order" do
    get "/override_dummy_order"
    assert_match "{\"new_name\":\"desc\"}", @response.body
  end
end
