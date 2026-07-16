# frozen_string_literal: true

require "test_helper"

class Settings::AppearancesControllerTest < ActionDispatch::IntegrationTest
  test "should show personal setting" do
    login
    get setting_appearance_url

    assert_response :success
  end
end
