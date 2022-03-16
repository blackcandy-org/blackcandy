# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should show setting" do
    assert_login_access(url: setting_url) do
      assert_response :success
    end
  end

  test "should update global setting" do
    Setting.update(discogs_token: "token")

    assert_admin_access(
      method: :patch,
      url: setting_url,
      params: {setting: {discogs_token: "updated_token"}},
      xhr: true
    ) do
      assert_equal "updated_token", Setting.discogs_token
    end
  end

  test "should sync media when media_path setting updated" do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))

    assert_enqueued_with(job: MediaSyncJob) do
      assert_admin_access(
        method: :patch,
        url: setting_url,
        params: {setting: {media_path: Rails.root.join("test/fixtures")}},
        xhr: true
      ) do
        assert_equal Rails.root.join("test/fixtures").to_s, Setting.media_path
      end
    end
  end
end
