# frozen_string_literal: true

require "test_helper"

class Settings::TranscodingsControllerTest < ActionDispatch::IntegrationTest
  test "should show transcoding setting" do
    login users(:admin)
    get settings_transcoding_url

    assert_response :success
    assert_select "h2", text: I18n.t("label.transcoding")
  end

  test "should update transcoding setting" do
    login users(:admin)
    patch settings_transcoding_url, params: { setting: { transcode_bitrate: 192 } }, xhr: true

    assert_equal 192, Setting.transcode_bitrate
  end

  test "should only admin can update transcoding settings" do
    login

    patch settings_transcoding_url, params: { setting: { transcode_bitrate: 192 } }
    assert_response :forbidden
  end

  test "should not update transcoding settings when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      patch settings_transcoding_url, params: { setting: { transcode_bitrate: 192 } }
      assert_response :forbidden
    end
  end
end
