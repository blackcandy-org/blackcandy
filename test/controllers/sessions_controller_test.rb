# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  SAFARI_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"

  setup do
    @user = users(:visitor1)
    @admin = users(:admin)

    Current.ip_address = "10.0.0.9"
    Current.user_agent = SAFARI_USER_AGENT

    @visitor_session = users(:visitor2).sessions.create!
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

  test "should get index" do
    login @admin
    get sessions_url

    assert_response :success
  end

  test "should revoke session" do
    login @admin

    assert_difference -> { Session.count }, -1 do
      delete session_url(@visitor_session)
    end

    assert_redirected_to sessions_url
    assert_not Session.exists?(@visitor_session.id)
  end

  test "should not revoke current session" do
    login @admin
    current_session = @admin.sessions.last

    delete session_url(current_session)

    assert_response :forbidden
    assert Session.exists?(current_session.id)
  end

  test "should only admin can access" do
    login

    get sessions_url
    assert_response :forbidden

    delete session_url(@visitor_session)
    assert_response :forbidden
  end

  test "should not let user access when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login @admin

      get sessions_url
      assert_response :forbidden

      delete session_url(@visitor_session)
      assert_response :forbidden
    end
  end

  test "should get index via api" do
    get sessions_url, as: :json, headers: api_token_header(@admin)
    response = @response.parsed_body

    assert_response :success

    visitor_session_response = response.find { |item| item["id"] == @visitor_session.id }

    assert_equal users(:visitor2).id, visitor_session_response["user_id"]
    assert_equal users(:visitor2).email, visitor_session_response["email"]
    assert_equal "10.0.0.9", visitor_session_response["ip_address"]
    assert_equal SAFARI_USER_AGENT, visitor_session_response["user_agent"]
    assert_not visitor_session_response["is_current"]

    assert response.find { |item| item["id"] == @admin.sessions.last.id }["is_current"]
  end

  test "should put current session on the top of index via api" do
    headers = api_token_header(@admin)
    current_session = @admin.sessions.last
    current_session.update_column(:created_at, 1.day.ago)
    users(:visitor1).sessions.create!

    get sessions_url, as: :json, headers: headers

    assert_equal current_session.id, @response.parsed_body.first["id"]
  end

  test "should revoke session via api" do
    headers = api_token_header(@admin)

    assert_difference -> { Session.count }, -1 do
      delete session_url(@visitor_session), as: :json, headers: headers
    end

    assert_response :no_content
  end

  test "should not revoke current session via api" do
    headers = api_token_header(@admin)
    current_session = @admin.sessions.last

    delete session_url(current_session), as: :json, headers: headers

    assert_response :forbidden
    assert_equal "Forbidden", @response.parsed_body["type"]
    assert Session.exists?(current_session.id)
  end

  test "should not let non-admin user access via api" do
    get sessions_url, as: :json, headers: api_token_header(@user)
    assert_response :forbidden

    delete session_url(@visitor_session), as: :json, headers: api_token_header(@user)
    assert_response :forbidden
  end
end
