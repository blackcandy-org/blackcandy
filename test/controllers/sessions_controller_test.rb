# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
  end

  test "should get new session" do
    get new_session_url
    assert_response :success
  end

  test "should redirect to root when user logged in" do
    login users(:visitor1)
    get new_session_url

    assert_redirected_to root_url
  end

  test "should create session" do
    post sessions_url, params: { session: { email: @user.email, password: "foobar" } }

    assert_redirected_to root_url
    assert_not_empty cookies[:session_id]
    assert_not_empty @user.sessions
  end

  test "should has error flash when failed to create session" do
    post sessions_url, params: { session: { email: @user.email, password: "fake" } }
    assert flash[:alert].present?
    assert_empty @user.sessions
  end


  test "should create session via api" do
    post sessions_url, as: :json, params: {
      session: {
        email: @user.email,
        password: "foobar"
      }
    }

    response = @response.parsed_body["user"]

    assert_response :success
    assert_not_empty cookies[:session_id]
    assert_not_empty @user.sessions
    assert_not_empty response["api_token"]
    assert_equal @user.id, response["id"]
    assert_equal @user.email, response["email"]
    assert_equal @user.is_admin, response["is_admin"]
  end

  test "should not create session via api with wrong credential" do
    post sessions_url, as: :json, params: {
      session: {
        email: "fake@email.com",
        password: "fake"
      }
    }

    assert_response :unauthorized
    assert_nil cookies[:session_id]
    assert_empty @user.sessions
  end

  test "should get error message via api with wrong credential" do
    post sessions_url, as: :json, params: {
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
end
