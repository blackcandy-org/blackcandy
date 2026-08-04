# frozen_string_literal: true

require "test_helper"

module My
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:visitor1)
      login @user
    end

    test "should get edit" do
      get edit_my_profile_url
      assert_response :success
    end

    test "should update current user" do
      patch my_profile_url, params: { user: { email: "visitor_updated@blackcandy.com" } }
      assert_equal "visitor_updated@blackcandy.com", @user.reload.email
    end

    test "should has error flash when failed to update" do
      patch my_profile_url, params: { user: { email: "invalid" } }
      assert flash[:alert].present?
    end

    test "should update current user via api" do
      patch my_profile_url,
        params: { user: { email: "visitor_updated@blackcandy.com" } },
        as: :json,
        headers: api_token_header(@user)

      assert_response :success
      assert_equal "visitor_updated@blackcandy.com", @user.reload.email
      assert_equal "visitor_updated@blackcandy.com", @response.parsed_body["email"]
    end

    test "should return error response when failed to update via api" do
      patch my_profile_url,
        params: { user: { email: "invalid" } },
        as: :json,
        headers: api_token_header(@user)

      assert_response :unprocessable_entity
      assert_equal "RecordInvalid", @response.parsed_body["type"]
      assert @response.parsed_body["message"].present?
    end

    test "should not let user access when is on demo mode" do
      with_env("DEMO_MODE" => "true") do
        login @user

        get edit_my_profile_url
        assert_response :forbidden

        patch my_profile_url, params: { user: { email: "visitor_updated@blackcandy.com" } }
        assert_response :forbidden
      end
    end
  end
end
