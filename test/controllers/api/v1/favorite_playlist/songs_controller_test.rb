require "test_helper"

class Api::V1::FavoritePlaylist::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.favorite_playlist
    @playlist.song_ids = [1, 2]
  end

  test "should add songs to playlist" do
    post api_v1_favorite_playlist_songs_url, params: {song_id: 3}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 3, response["id"]
    assert response["is_favorited"]
    assert_equal [3, 1, 2], @playlist.reload.song_ids
  end

  test "should remove songs from playlist" do
    delete api_v1_favorite_playlist_song_url(id: 1), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 1, response["id"]
    assert_not response["is_favorited"]
    assert_equal [2], @playlist.reload.song_ids

    delete api_v1_favorite_playlist_song_url(id: 2), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 2, response["id"]
    assert_not response["is_favorited"]
    assert_equal [], @playlist.reload.song_ids
  end

  test "should not add song to playlist if already in playlist" do
    post api_v1_favorite_playlist_songs_url, params: {song_id: 1}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :bad_request
    assert_equal "DuplicatePlaylistSong", response["type"]
    assert_not_empty response["message"]
  end
end
