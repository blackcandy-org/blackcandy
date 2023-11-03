# frozen_string_literal: true

require "test_helper"

class Api::V1::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
  end

  test "should create authentication without session" do
    post api_v1_authentication_url, as: :json, params: {
      session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    assert_response :success
    assert_nil cookies[:session_id]
    assert_not_empty @user.sessions
    assert_not_empty response["api_token"]
    assert_equal @user.id, response["id"]
    assert_equal @user.email, response["email"]
    assert_equal @user.is_admin, response["is_admin"]
  end

  test "should create authentication with session" do
    post api_v1_authentication_url, as: :json, params: {
      with_cookie: true,
      session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    assert_response :success
    assert_not_empty cookies[:session_id]
    assert_not_empty response["api_token"]
    assert_not_empty @user.sessions
    assert_equal @user.id, response["id"]
    assert_equal @user.email, response["email"]
    assert_equal @user.is_admin, response["is_admin"]
  end

  test "should not create authentication with wrong credential" do
    post api_v1_authentication_url, as: :json, params: {
      session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    assert_response :unauthorized
    assert_nil cookies[:session_id]
    assert_empty @user.sessions
  end

  test "should not create authentication and session with wrong credential" do
    post api_v1_authentication_url, as: :json, params: {
      with_cookie: true,
      session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    assert_response :unauthorized
    assert_nil cookies[:session_id]
    assert_empty @user.sessions
  end

  test "should get error message with wrong credential" do
    post api_v1_authentication_url, as: :json, params: {
      session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    response = @response.parsed_body

    assert_response :unauthorized
    assert_equal "InvalidCredential", response["type"]
    assert_not_empty response["message"]
  end

  test "should destroy authentication" do
    post api_v1_authentication_url, as: :json, params: {
      session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    delete api_v1_authentication_url, as: :json, headers: {
      authorization: ActionController::HttpAuthentication::Token.encode_credentials(response["api_token"])
    }

    assert_response :success
    assert_empty @user.sessions
  end
end
