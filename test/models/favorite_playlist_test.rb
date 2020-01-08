# frozen_string_literal: true

require 'test_helper'

class FavoritePlaylistTest < ActiveSupport::TestCase
  test 'should not need name' do
    assert FavoritePlaylist.new(name: nil, user: users(:admin)).valid?
  end
end
