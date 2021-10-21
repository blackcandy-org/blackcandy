# frozen_string_literal: true

require 'application_system_test_case'

class UsersSystemTest < ApplicationSystemTestCase
  setup do
    login_as users(:admin)
  end

  test 'show users' do
    visit users_url

    User.where.not(id: users(:admin)).each do |user|
      assert_text(user.email)
    end
  end

  test 'add user' do
    visit users_url
    click_on 'Add user'

    fill_in 'Email', with: 'system_test@test.com'
    fill_in 'Password', with: 'foobar'
    fill_in 'Password confirmation', with: 'foobar'
    click_on 'Save'

    assert_text('Created successfully')
    assert_text('system_test@test.com')
  end

  test 'delete user' do
    visit users_url

    delete_user = users(:visitor1)
    delete_user_button = find("#user_#{delete_user.id}").find('button')
    delete_user_button.click

    assert_text('Delete successfully')
    assert_no_text(delete_user.email)
  end

  test 'edit user' do
    visit edit_user_url(users(:visitor1))

    fill_in 'Email', with: 'system_test@test.com'
    click_on 'Save'

    assert_equal 'system_test@test.com', find_field('user_email').value
  end
end
