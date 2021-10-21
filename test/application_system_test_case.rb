# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:system'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 900]

  def login_as(user)
    visit new_session_url

    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'foobar'

    click_on 'Login'

    assert_current_path(albums_url)
  end
end

Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.default_normalize_ws = true
end
