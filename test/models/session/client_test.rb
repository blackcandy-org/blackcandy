# frozen_string_literal: true

require "test_helper"

class Session::ClientTest < ActiveSupport::TestCase
  SAFARI_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
  CHROME_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  IOS_APP_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Black Candy iOS/1.0"
  ANDROID_APP_USER_AGENT = "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 Black Candy Android/1.0"

  test "should get client name and platform from browser user agent" do
    session = Session.new(user_agent: SAFARI_USER_AGENT)

    assert_equal "Safari", session.client_name
    assert_equal "macOS", session.client_platform
    assert_not session.ios?
    assert_not session.android?

    session = Session.new(user_agent: CHROME_USER_AGENT)

    assert_equal "Chrome", session.client_name
    assert_equal "Generic Linux", session.client_platform
  end

  test "should get client name from native app user agent" do
    session = Session.new(user_agent: IOS_APP_USER_AGENT)

    assert session.ios?
    assert_equal "Black Candy iOS", session.client_name
    assert_equal "iOS (iPhone)", session.client_platform

    session = Session.new(user_agent: ANDROID_APP_USER_AGENT)

    assert session.android?
    assert_equal "Black Candy Android", session.client_name
    assert_equal "Android", session.client_platform
  end

  test "should get unknown client name from unknown user agent" do
    session = Session.new(user_agent: nil)

    assert_equal "Unknown Client", session.client_name
    assert_nil session.client_platform
  end
end
