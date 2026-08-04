# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    login users(:admin)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new user" do
    get new_user_url
    assert_response :success
  end

  test "should edit user" do
    get edit_user_url(users(:visitor1))
    assert_response :success
  end

  test "should create user" do
    users_count = User.count

    post users_url, params: { user: { email: "test@test.com", password: "foobar" } }
    assert_equal users_count + 1, User.count
  end

  test "should has error flash when failed to create user" do
    post users_url, params: { user: { email: "test.com", password: "foobar" } }
    assert flash[:alert].present?
  end

  test "should update user" do
    user = users(:visitor1)

    patch user_url(user), params: { user: { email: "visitor_updated@blackcandy.com" } }
    assert_equal "visitor_updated@blackcandy.com", user.reload.email
  end

  test "should has error flash when failed to update user" do
    patch user_url(users(:visitor1)), params: { user: { email: "test.com", password: "foobar" } }
    assert flash[:alert].present?
  end

  test "should destroy user" do
    users_count = User.count

    delete user_url(users(:visitor2))
    assert_equal users_count - 1, User.count
  end

  test "should not let user destroy self" do
    delete user_url(users(:admin))
    assert_response :forbidden
  end

  test "should only admin can access" do
    login

    get users_url
    assert_response :forbidden

    get new_user_url
    assert_response :forbidden

    get edit_user_url(users(:visitor2))
    assert_response :forbidden

    post users_url, params: { user: { email: "test@test.com", password: "foobar" } }
    assert_response :forbidden

    patch user_url(users(:visitor2)), params: { user: { email: "visitor_updated@blackcandy.com" } }
    assert_response :forbidden

    delete user_url(users(:visitor2))
    assert_response :forbidden
  end

  test "should get index via api" do
    get users_url, as: :json, headers: api_token_header(users(:admin))
    response = @response.parsed_body

    assert_response :success

    user = users(:visitor1)
    user_response = response.find { |item| item["id"] == user.id }

    assert_equal user.email, user_response["email"]
    assert_equal user.is_admin, user_response["is_admin"]
    assert_nil response.find { |item| item["id"] == users(:admin).id }
  end

  test "should create user via api" do
    assert_difference -> { User.count }, 1 do
      post users_url,
        params: { user: { email: "newuser@test.com", password: "foobar" } },
        as: :json,
        headers: api_token_header(users(:admin))
    end

    assert_response :created
    assert_equal "newuser@test.com", @response.parsed_body["email"]
  end

  test "should return error response when failed to create user via api" do
    post users_url,
      params: { user: { email: "invalid", password: "foobar" } },
      as: :json,
      headers: api_token_header(users(:admin))

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should update user via api" do
    user = users(:visitor1)

    patch user_url(user),
      params: { user: { email: "visitor_updated@blackcandy.com" } },
      as: :json,
      headers: api_token_header(users(:admin))

    assert_response :success
    assert_equal "visitor_updated@blackcandy.com", user.reload.email
    assert_equal "visitor_updated@blackcandy.com", @response.parsed_body["email"]
  end

  test "should return error response when failed to update user via api" do
    patch user_url(users(:visitor1)),
      params: { user: { email: "invalid" } },
      as: :json,
      headers: api_token_header(users(:admin))

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should destroy user via api" do
    assert_difference -> { User.count }, -1 do
      delete user_url(users(:visitor2)), as: :json, headers: api_token_header(users(:admin))
    end

    assert_response :no_content
  end

  test "should not let user destroy self via api" do
    delete user_url(users(:admin)), as: :json, headers: api_token_header(users(:admin))

    assert_response :forbidden
    assert_equal "Forbidden", @response.parsed_body["type"]
  end

  test "should not let non-admin user update via api" do
    cookies[:session_id] = nil

    patch user_url(users(:visitor1)),
      params: { user: { email: "visitor_updated@blackcandy.com" } },
      as: :json,
      headers: api_token_header(users(:visitor1))

    assert_response :forbidden
  end

  test "should not let user access when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get users_url
      assert_response :forbidden

      get new_user_url
      assert_response :forbidden

      post users_url, params: { user: { email: "test@test.com", password: "foobar" } }
      assert_response :forbidden

      delete user_url(users(:visitor2))
      assert_response :forbidden

      get edit_user_url(users(:visitor2))
      assert_response :forbidden

      patch user_url(users(:visitor2)), params: { user: { email: "visitor_updated@blackcandy.com" } }
      assert_response :forbidden
    end
  end
end
