# frozen_string_literal: true

require "test_helper"

class Users::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should update user settings" do
    current_user = users(:visitor1)
    assert_equal "dark", current_user.theme

    login current_user
    patch user_setting_url(current_user), params: {user: {theme: "light"}}, xhr: true

    assert_equal "light", current_user.reload.theme
  end

  test "should only user themself can update their settings" do
    login users(:admin)

    patch user_setting_url(users(:visitor1)), params: {user: {theme: "light"}}, xhr: true
    assert_response :forbidden
  end
end
