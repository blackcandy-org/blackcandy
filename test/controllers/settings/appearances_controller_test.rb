# frozen_string_literal: true

require "test_helper"

class Settings::AppearancesControllerTest < ActionDispatch::IntegrationTest
  test "should show personal setting" do
    login
    get settings_appearance_url

    assert_response :success
  end
end
