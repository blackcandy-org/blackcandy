# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"

SimpleCov.command_name "test:system"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite, screen_size: [1400, 900], options: {
    browser_options: {"no-sandbox": nil},
    url_blacklist: ["https://www.gravatar.com"],
    timeout: 10,
    process_timeout: 20
  }

  def login_as(user)
    visit new_session_url

    fill_in "Email", with: user.email
    fill_in "Password", with: "foobar"
    click_on "Login"

    assert_current_path root_url
  end
end

Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.default_normalize_ws = true
  config.test_id = "data-test-id"
end

Capybara.add_selector(:test_id) do
  xpath do |locator|
    XPath.descendant[XPath.attr(Capybara.test_id) == locator]
  end
end
