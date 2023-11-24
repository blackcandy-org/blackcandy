require "test_helper"

class Api::V1::CurrentPlaylist::Songs::PlaylistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
    @current_playlist = @user.current_playlist
  end

  test "should replace all songs with playlist songs" do
    playlist = @user.playlists.create(name: "test", song_ids: [1, 2, 3])

    put api_v1_current_playlist_playlist_url(playlist), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal playlist.song_ids, @current_playlist.song_ids
    assert_equal playlist.song_ids, response.map { |song| song["id"] }
  end

  test "should return not found when playlist not found" do
    put api_v1_current_playlist_playlist_url(id: "invalid_id"), as: :json, headers: api_token_header(@user)

    assert_response :not_found
  end

  test "should return not found when playlist is not owned by user" do
    playlist = users(:visitor1).playlists.create(name: "test", song_ids: [1, 2, 3])

    put api_v1_current_playlist_playlist_url(playlist), as: :json, headers: api_token_header(@user)

    assert_response :not_found
    assert_empty @current_playlist.song_ids
  end
end
