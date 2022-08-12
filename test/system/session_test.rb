# frozen_string_literal: true

require "application_system_test_case"

class SessionSystemTest < ApplicationSystemTestCase
  test "login" do
    visit new_session_url

    fill_in "Email", with: users(:visitor1).email
    fill_in "Password", with: "foobar"

    click_on "Login"

    assert_current_path(root_url)
  end

  test "login with wrong credentials" do
    visit new_session_url

    fill_in "Email", with: users(:visitor1).email
    fill_in "Password", with: "wrong_pass"

    click_on "Login"

    # assert have error flash message
    assert_text("Wrong email or password")

    # after login failed, cleanup login form
    assert_field "Email", with: ""
    assert_field "Password", with: ""
  end

  test "logout" do
    login_as users(:visitor1)
    find(:test_id, "search_bar_menu").click
    click_on "Logout"

    assert_current_path(new_session_url)
  end
end
