# frozen_string_literal: true

require "test_helper"

class ScopedSettingTest < ActiveSupport::TestCase
  test "should have AVAILABLE_SETTINGS constant" do
    assert_equal [:theme], User::AVAILABLE_SETTINGS
  end

  test "should get default value when setting value did not set" do
    user = users(:visitor1)

    assert_nil user.settings&.fetch("theme")
    assert_equal User::DEFAULT_THEME, user.theme
  end

  test "should update settings" do
    user = users(:visitor1)
    assert_equal "dark", user.theme

    user.theme = "light"
    user.save

    assert_equal "light", user.reload.theme
  end

  test "should avoid others option value when set available_options" do
    user = users(:visitor1)
    assert_equal "dark", user.theme

    user.theme = "fake_theme"
    user.save

    assert_not user.valid?
    assert_equal "dark", user.reload.theme
  end
end
