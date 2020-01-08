# frozen_string_literal: true

require 'test_helper'

class CurrentPlaylistTest < ActiveSupport::TestCase
  test 'should not need name' do
    assert CurrentPlaylist.new(name: nil, user: users(:admin)).valid?
  end
end
