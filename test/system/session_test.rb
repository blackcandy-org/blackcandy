# frozen_string_literal: true

require 'application_system_test_case'

class SessionTest < ApplicationSystemTestCase
  test 'login' do
    visit new_session_url

    fill_in 'Email', with: users(:visitor1).email
    fill_in 'Password', with: 'foobar'

    click_on 'Login'

    assert_current_path(albums_url)
  end

  test 'login with wrong credentials' do
    visit new_session_url

    fill_in 'Email', with: users(:visitor1).email
    fill_in 'Password', with: 'wrong_pass'

    click_on 'Login'

    # after login failed, cleanup login form
    assert_field 'Email', text: ''
    assert_field 'Password', text: ''

    # assert have error flash message
    assert_text('Wrong email or password')
  end

  test 'logout' do
    login_as users(:visitor1)
    find('#test-main-content header .c-avatar').click
    click_on 'Logout'

    assert_current_path(new_session_url)
  end
end
