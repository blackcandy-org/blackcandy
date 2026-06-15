# frozen_string_literal: true

require "test_helper"

class Settings::LibrariesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should show library setting" do
    login users(:admin)
    get settings_library_url

    assert_response :success
  end

  test "should not show library setting for non admin users" do
    login
    get settings_library_url

    assert_response :forbidden
  end

  test "should sync media when media_path setting updated" do
    login users(:admin)

    assert_enqueued_with(job: MediaSyncAllJob) do
      patch settings_library_url, params: { setting: { media_path: Rails.root.join("test/fixtures") } }
      assert_equal Rails.root.join("test/fixtures").to_s, Setting.media_path
    end
  end

  test "should only admin can update library settings" do
    login

    patch settings_library_url, params: { setting: { media_path: Rails.root.join("test/fixtures") } }
    assert_response :forbidden
  end

  test "should not update library settings when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      patch settings_library_url, params: { setting: { media_path: Rails.root.join("test/fixtures") } }
      assert_response :forbidden
    end
  end
end
