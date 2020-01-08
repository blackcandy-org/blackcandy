# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'format_duration' do
    assert_equal '00:09', format_duration(9)
    assert_equal '01:30', format_duration(90)
    assert_equal '15:00', format_duration(900)
    assert_equal '02:30:00', format_duration(9000)
  end

  test 'next_url_for_path' do
    pagy = {}

    pagy.define_singleton_method(:next) do
      2
    end

    pagy.define_singleton_method(:vars) do
      { page_param: :page }
    end

    assert_equal '/playlist?page=2', next_url_for_path('/playlist', pagy)
    assert_equal '/playlist?test=fire&page=2', next_url_for_path('/playlist?test=fire', pagy)
  end
end
