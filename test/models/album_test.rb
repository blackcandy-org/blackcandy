# frozen_string_literal: true

require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  test 'should not have same name album on an artist' do
    artists(:artist1).albums.create(name: 'best')
    assert_not artists(:artist1).albums.build(name: 'best').valid?
  end

  test 'should have default title when name is empty' do
    assert_equal 'Unknown Album', Album.create(name: nil).title
  end
end
