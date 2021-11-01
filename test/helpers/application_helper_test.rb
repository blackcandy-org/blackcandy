# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'format_duration' do
    assert_equal '00:09', format_duration(9)
    assert_equal '01:30', format_duration(90)
    assert_equal '15:00', format_duration(900)
    assert_equal '02:30:00', format_duration(9000)
  end

  test 'shelf grid tag with class option' do
    tag_content = '<div class="o-grid o-grid--gap-medium test" '\
      'cols@narrow="2" cols@extra-small="3" cols@small="2" cols@medium="3" '\
      'cols@large="4" cols@extra-large="5" cols@wide="6" cols@extra-wide="7"></div>'

    assert_equal tag_content, shelf_grid_tag(class: 'test')
  end

  test 'shelf grid tag with block content' do
    tag_content = '<div class="o-grid o-grid--gap-medium " '\
      'cols@narrow="2" cols@extra-small="3" cols@small="2" cols@medium="3" '\
      'cols@large="4" cols@extra-large="5" cols@wide="6" cols@extra-wide="7"><p>test</p></div>'

    shelf_tag = shelf_grid_tag do
      tag.p 'test'
    end

    assert_equal tag_content, shelf_tag
  end
end
