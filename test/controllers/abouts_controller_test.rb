# frozen_string_literal: true

require "test_helper"

class AboutsControllerTest < ActionDispatch::IntegrationTest
  test "should show about" do
    login
    get about_url

    assert_response :success
  end
end
