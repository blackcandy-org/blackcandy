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
    assert_not response.any? { |song| song["is_favorited"] }
  end

  test "should remove songs from playlist" do
    delete api_v1_current_playlist_song_url(id: 1), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 1, response["id"]
    assert_equal [2, 3], @playlist.reload.song_ids

    delete api_v1_current_playlist_song_url(id: 3), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 3, response["id"]
    assert_equal [2], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist" do
    delete api_v1_current_playlist_songs_url, headers: api_token_header(@user)

    assert_response :success
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist" do
    assert_equal [1, 2, 3], @playlist.song_ids

    put move_api_v1_current_playlist_song_url(id: 1), params: {destination_song_id: 2}, headers: api_token_header(@user)
    assert_response :success
    assert_equal [2, 1, 3], @playlist.reload.song_ids

    put move_api_v1_current_playlist_song_url(id: 3), params: {destination_song_id: 2}, headers: api_token_header(@user)
    assert_response :success
    assert_equal [3, 2, 1], @playlist.reload.song_ids
  end

  test "should return not found when reorder song not in playlist" do
    put move_api_v1_current_playlist_song_url(id: 4), params: {destination_song_id: 2}, as: :json, headers: api_token_header(@user)
    assert_response :not_found
  end

  test "should add song next to the current song when current song did set" do
    post api_v1_current_playlist_songs_url, params: {song_id: 4, current_song_id: 1}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 4, response["id"]
    assert_equal [1, 4, 2, 3], @playlist.reload.song_ids
  end

  test "should add song to the first position when current song did not set" do
    post api_v1_current_playlist_songs_url, params: {song_id: 4}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 4, response["id"]
    assert_equal [4, 1, 2, 3], @playlist.reload.song_ids
  end

  test "should add song to the last position when set location param to last" do
    post api_v1_current_playlist_songs_url, params: {song_id: 4, location: "last"}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal 4, response["id"]
    assert_equal [1, 2, 3, 4], @playlist.reload.song_ids
  end

  test "should not add song to playlist if already in playlist" do
    post api_v1_current_playlist_songs_url, params: {song_id: 1}, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :bad_request
    assert_equal "DuplicatePlaylistSong", response["type"]
    assert_not_empty response["message"]
  end
end
