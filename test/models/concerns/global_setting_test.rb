# frozen_string_literal: true

require "test_helper"

class GlobalSettingTest < ActiveSupport::TestCase
  test "should have AVAILABLE_SETTINGS constant" do
    assert_equal [:media_path, :discogs_token], Setting::AVAILABLE_SETTINGS
  end

  test "should get env default value when setting value did not set" do
    ENV["MEDIA_PATH"] = "/test_media_path"

    assert_nil Setting.instance.values&.fetch("media_path")
    assert_equal "/test_media_path", Setting.media_path
  end

  test "should get singleton global setting" do
    assert_equal Setting.instance, Setting.instance
  end

  test "should update settings" do
    assert_nil Setting.discogs_token

    Setting.update(discogs_token: "token")

    assert_equal "token", Setting.discogs_token
  end
end
