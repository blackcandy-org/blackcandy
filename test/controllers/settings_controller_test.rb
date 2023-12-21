# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should show setting" do
    login
    get setting_url

    assert_response :success
  end

  test "should update global setting" do
    Setting.update(discogs_token: "token")

    login users(:admin)
    patch setting_url, params: {setting: {discogs_token: "updated_token"}}, xhr: true

    assert_equal "updated_token", Setting.discogs_token
  end

  test "should has error flash when failed to update" do
    login users(:admin)
    patch setting_url, params: {setting: {transcode_bitrate: 11}}, xhr: true

    assert flash[:error].present?
  end

  test "should sync media when media_path setting updated" do
    login users(:admin)

    assert_enqueued_with(job: MediaSyncJob) do
      patch setting_url, params: {setting: {media_path: Rails.root.join("test/fixtures")}}, xhr: true
      assert_equal Rails.root.join("test/fixtures").to_s, Setting.media_path
    end
  end

  test "should only admin can update global settings" do
    login

    patch setting_url, params: {setting: {discogs_token: "updated_token"}}, xhr: true
    assert_response :forbidden
  end

  test "should not update global settings when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      patch setting_url, params: {setting: {discogs_token: "updated_token"}}, xhr: true
      assert_response :forbidden
    end
  end
end
