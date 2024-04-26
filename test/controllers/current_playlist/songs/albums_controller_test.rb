require "test_helper"

class CurrentPlaylist::Songs::AlbumControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.current_playlist

    login @user
  end

  test "should replace all songs with album songs" do
    put current_playlist_album_url(albums(:album1), should_play: true)

    assert_redirected_to current_playlist_songs_url(should_play: true)
    assert_equal albums(:album1).song_ids, @playlist.song_ids
  end

  test "should return not found when album not found" do
    put current_playlist_album_url(id: "invalid_id")

    assert_response :not_found
  end

  test "should add album to recently played" do
    assert_difference -> { @user.reload.recently_played_albums.count } do
      put current_playlist_album_url(albums(:album1))
    end
  end
end
