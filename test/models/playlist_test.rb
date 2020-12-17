# frozen_string_literal: true

require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  test 'should have name' do
    assert_not Playlist.new(name: nil, user: users(:admin)).valid?
  end

  test 'should raise error when song already in playlist' do
    assert_raises(ActiveRecord::RecordNotUnique) do
      playlists(:playlist1).songs.push songs(:mp3_sample)
    end
  end

  test 'should get songs ordered by the position when the song pushed to the playlist' do
    playlist = Playlist.create(name: 'test', user: users(:admin))
    playlist.songs.push songs(:flac_sample)
    playlist.songs.push songs(:opus_sample)
    playlist.songs.push songs(:m4a_sample)

    assert_equal %w[flac_sample opus_sample m4a_sample], playlist.reload.songs.pluck(:name)
  end

  test 'should replace whole songs' do
    song_ids = Song.where(name: %w[flac_sample opus_sample m4a_sample]).ids
    playlist = playlists(:playlist1)

    assert_changes -> { playlist.reload.song_ids == song_ids }, from: false, to: true do
      playlist.replace(song_ids)
    end
  end
end
