# frozen_string_literal: true

require "test_helper"

class Api::V1::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
  end

  test "should create authentication without session" do
    post api_v1_authentication_url, as: :json, params: {
      user_session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    assert_response :success
    assert_nil session[:user_credentials]
    assert_equal @user.reload.api_token, response["api_token"]
    assert_equal @user.id, response["id"]
    assert_equal @user.email, response["email"]
    assert_equal @user.is_admin, response["is_admin"]
  end

  test "should create authentication with session" do
    post api_v1_authentication_url, as: :json, params: {
      with_session: true,
      user_session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    assert_response :success
    assert_not_nil session[:user_credentials]
    assert_equal @user.reload.api_token, response["api_token"]
    assert_equal @user.id, response["id"]
    assert_equal @user.email, response["email"]
    assert_equal @user.is_admin, response["is_admin"]
  end

  test "should not create authentication with wrong credential" do
    post api_v1_authentication_url, as: :json, params: {
      user_session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    assert_response :unauthorized
    assert_nil session[:user_credentials]
    assert_empty @response.body
  end

  test "should not create authentication and session with wrong credential" do
    post api_v1_authentication_url, as: :json, params: {
      with_session: true,
      user_session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    assert_response :unauthorized
    assert_nil session[:user_credentials]
    assert_empty @response.body
  end
end
