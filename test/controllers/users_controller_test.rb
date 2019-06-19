# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_admin_access(:get, users_url) do
      assert_response :success
    end
  end

  test 'should get new user' do
    assert_admin_access(:get, new_user_url) do
      assert_response :success
    end
  end

  test 'should edit user' do
    current_user = users(:visitor1)

    assert_self_or_admin_access(current_user, :get, edit_user_url(current_user)) do
      assert_response :success
    end
  end

  test 'should create user' do
    user_params = { user: { email: 'test@test.com', password: 'foobar' } }
    users_count = User.count

    assert_admin_access(:post, users_url, params: user_params) do
      assert_equal users_count + 1, User.count
    end
  end

  test 'should update user' do
    current_user = users(:visitor1)
    user_params = { user: { email: 'visitor_updated@blackcandy.com', password: 'foobar' } }

    assert_self_or_admin_access(current_user, :patch, user_url(current_user), params: user_params, xhr: true) do
      assert_equal 'visitor_updated@blackcandy.com', current_user.reload.email
    end
  end

  test 'should destroy user' do
    users_count = User.count

    assert_admin_access(:delete, user_url(users(:visitor2)), xhr: true) do
      assert_equal users_count - 1, User.count
    end
  end

  test 'should not let user destroy self' do
    assert_admin_access(:delete, user_url(users(:admin)), xhr: true) do
      assert_response :forbidden
    end
  end
end
