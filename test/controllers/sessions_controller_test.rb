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
    post session_url, params: {user_session: {email: @user.email, password: "foobar"}}

    assert_redirected_to root_url
    assert_not_nil session[:user_credentials]
    assert_not_empty cookies[:user_id]
  end

  test "should has error flash when failed to create session" do
    post session_url, params: {user_session: {email: @user.email, password: "fake"}}, xhr: true
    assert flash[:error].present?
  end

  test "should destroy session" do
    login @user
    delete session_url

    assert_nil session[:user_credentials]
    assert_empty cookies[:user_id]
    assert_redirected_to new_session_url
  end

  test "should have forgery protection" do
    with_forgery_protection do
      login @user

      assert_nil session[:user_credentials]
      assert_nil cookies[:user_id]
      assert_redirected_to new_session_url
    end
  end
end
