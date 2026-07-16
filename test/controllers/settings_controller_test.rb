# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    login users(:admin)
    get setting_url

    assert_response :success
  end
end
