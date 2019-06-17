# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'should format duration' do
    assert_equal '00:09', formatDuration(9)
    assert_equal '01:30', formatDuration(90)
    assert_equal '15:00', formatDuration(900)
    assert_equal '02:30:00', formatDuration(9000)
  end
end
