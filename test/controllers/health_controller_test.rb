# frozen_string_literal: true

require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  class DummyHealthController < HealthController
    def show
      raise "error"
    end
  end

  test "should return ok" do
    get up_url
    assert_response :success
  end

  test "should return 500 when exception raised" do
    HealthController.stub(:new, DummyHealthController.new) do
      get up_url
      assert_response :internal_server_error
    end
  end
end
