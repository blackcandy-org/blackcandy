# frozen_string_literal: true

require "test_helper"

class Settings::IntegrationsControllerTest < ActionDispatch::IntegrationTest
  test "should show integration setting" do
    login users(:admin)
    get settings_integration_url

    assert_response :success
  end

  test "should update integration setting" do
    login users(:admin)
    patch settings_integration_url, params: { setting: { discogs_token: "updated_token" } }

    assert_equal "updated_token", Setting.discogs_token
  end

  test "should only admin can update integration settings" do
    login

    patch settings_integration_url, params: { setting: { discogs_token: "updated_token" } }
    assert_response :forbidden
  end

  test "should not update integration settings when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      patch settings_integration_url, params: { setting: { discogs_token: "updated_token" } }
      assert_response :forbidden
    end
  end
end
