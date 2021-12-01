# frozen_string_literal: true

require "test_helper"

class PlaylistsSongTest < ActiveSupport::TestCase
  test "should reorder songs list" do
    assert_changes -> { PlaylistsSong.where(playlist_id: 1).pluck(:song_id) }, from: [1, 2], to: [2, 1] do
      playlists_songs(:playlist1_mp3_sample).update(position: 2)
    end
  end
end
