# frozen_string_literal: true

require 'test_helper'

class SongTest < ActiveSupport::TestCase
  test 'should find songs in arbitrary order' do
    song_ids = Song.where(name: ['mp3_sample', 'm4a_sample', 'flac_sample']).ids.shuffle

    assert_equal song_ids, Song.find_ordered(song_ids).ids
  end
end
