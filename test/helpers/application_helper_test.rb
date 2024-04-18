# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format duration" do
    assert_equal "00:09", format_duration(9)
    assert_equal "01:30", format_duration(90)
    assert_equal "15:00", format_duration(900)
    assert_equal "02:30:00", format_duration(9000)
  end

  test "empty alert tag" do
    assert_includes empty_alert_tag, "No Items"
    assert_includes empty_alert_tag, "c-overlay"
    assert_not_includes empty_alert_tag, "c-icon"
    assert_includes empty_alert_tag(has_icon: true), "c-icon"
    assert_not_includes empty_alert_tag(has_overlay: false), "c-overlay"
  end

  test "format number" do
    assert_equal "135", format_number(135)
    assert_equal "1.4 K", format_number(1350)
    assert_equal "1.4 M", format_number(1350000)
    assert_equal "1.4 B", format_number(1350000000)
  end
end
