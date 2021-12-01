# frozen_string_literal: true

require "test_helper"

class FavoritePlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  test "should show favorite playlist songs" do
    assert_login_access(url: favorite_playlist_songs_url) do
      assert_response :success
    end
  end

  test "should play favorite playlist" do
    user = users(:visitor1)
    playlist = user.favorite_playlist
    playlist.song_ids = [1, 2]

    assert_not_equal playlist.song_ids, user.current_playlist.song_ids

    assert_login_access(
      user: user,
      method: :post,
      url: play_favorite_playlist_songs_url
    ) do
      assert_equal playlist.song_ids, user.current_playlist.reload.song_ids
    end
  end
end
