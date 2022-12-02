require "test_helper"

class Api::V1::CurrentPlaylist::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.current_playlist
    @playlist.song_ids = [1, 2, 3]
  end

  test "should show all songs" do
    get api_v1_current_playlist_songs_url, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal [1, 2, 3], response.map { |song| song["id"] }
    assert_equal [false, false, false], response.map { |song| song["is_favorited"] }
  end

  test "should remove songs from playlist" do
    delete api_v1_current_playlist_songs_url, params: {song_ids: [1]}, headers: api_token_header(@user)
    assert_equal [2, 3], @playlist.reload.song_ids

    delete api_v1_current_playlist_songs_url, params: {song_ids: [2, 3]}, headers: api_token_header(@user)
    assert_equal [], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist" do
    delete api_v1_current_playlist_songs_url, params: {clear_all: true}, headers: api_token_header(@user)
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist" do
    assert_equal [1, 2, 3], @playlist.song_ids

    put api_v1_current_playlist_songs_url, params: {from_position: 1, to_position: 2}, headers: api_token_header(@user)

    assert_equal [2, 1, 3], @playlist.reload.song_ids
  end
end
