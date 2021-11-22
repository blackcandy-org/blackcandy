# frozen_string_literal: true

require "test_helper"

class Users::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should update user settings" do
    current_user = users(:visitor1)
    setting_params = {user: {theme: "light"}}

    assert_equal "dark", current_user.theme

    assert_self_access(
      user: current_user,
      method: :patch,
      url: user_setting_url(current_user),
      params: setting_params,
      xhr: true
    ) do
      assert_equal "light", current_user.reload.theme
    end
  end
end
