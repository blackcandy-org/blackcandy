# frozen_string_literal: true

require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get forbidden" do
    get forbidden_url
    assert_response :forbidden
  end

  test "should get not found" do
    get not_found_url
    assert_response :not_found
  end

  test "should get unprocessable entity" do
    get unprocessable_entity_url
    assert_response :unprocessable_entity
  end

  test "should get internal server error" do
    get internal_server_error_url
    assert_response :internal_server_error
  end
end
