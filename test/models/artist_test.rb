# frozen_string_literal: true

require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  test 'should have default title when name is empty' do
    assert_equal 'Unknown Artist', Artist.create(name: nil).title
  end
end
