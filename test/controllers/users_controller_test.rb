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

  test "should user can edit themself" do
    user = users(:visitor1)

    login user
    get edit_user_url(user)
    assert_response :success

    login users(:visitor2)
    get edit_user_url(user)
    assert_response :forbidden
  end

  test "should create user" do
    users_count = User.count

    post users_url, params: {user: {email: "test@test.com", password: "foobar"}}
    assert_equal users_count + 1, User.count
  end

  test "should update user" do
    user = users(:visitor1)

    patch user_url(user), params: {user: {email: "visitor_updated@blackcandy.com"}}, xhr: true
    assert_equal "visitor_updated@blackcandy.com", user.reload.email
  end

  test "should user can update themself" do
    user = users(:visitor1)

    login user
    patch user_url(user), params: {user: {email: "visitor_updated@blackcandy.com"}}, xhr: true
    assert_equal "visitor_updated@blackcandy.com", user.reload.email

    login users(:visitor2)
    patch user_url(user), params: {user: {email: "visitor_updated@blackcandy.com"}}, xhr: true
    assert_response :forbidden
  end

  test "should destroy user" do
    users_count = User.count

    delete user_url(users(:visitor2)), xhr: true
    assert_equal users_count - 1, User.count
  end

  test "should not let user destroy self" do
    delete user_url(users(:admin)), xhr: true
    assert_response :forbidden
  end

  test "should only admin can access" do
    login

    get users_url
    assert_response :forbidden

    get new_user_url
    assert_response :forbidden

    post users_url, params: {user: {email: "test@test.com", password: "foobar"}}
    assert_response :forbidden

    delete user_url(users(:visitor2)), xhr: true
    assert_response :forbidden
  end
end
