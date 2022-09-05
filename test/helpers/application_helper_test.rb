# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format_duration" do
    assert_equal "00:09", format_duration(9)
    assert_equal "01:30", format_duration(90)
    assert_equal "15:00", format_duration(900)
    assert_equal "02:30:00", format_duration(9000)
  end
end
