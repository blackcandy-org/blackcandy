# frozen_string_literal: true

require "test_helper"

class Albums::Filter::YearsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get albums_filter_years_url

    assert_response :success
  end
end
