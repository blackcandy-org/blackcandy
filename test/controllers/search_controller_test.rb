# frozen_string_literal: true

require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get search_url(query: "test")

    assert_response :success
  end
end
