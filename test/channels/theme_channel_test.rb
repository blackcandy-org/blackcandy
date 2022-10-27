# frozen_string_literal: true

require "test_helper"

class ThemeChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for theme" do
    subscribe

    assert subscription.confirmed?
    assert_has_stream "theme_update"
  end
end
