require "test_helper"

class Api::V1::CurrentPlaylist::Songs::AlbumControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.current_playlist
  end

  test "should replace all songs with album songs" do
    put api_v1_current_playlist_album_url(albums(:album1)), as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal albums(:album1).song_ids, @playlist.song_ids
    assert_equal albums(:album1).song_ids, response.map { |song| song["id"] }
  end

  test "should return not found when album not found" do
    put api_v1_current_playlist_album_url(id: "invalid_id"), as: :json, headers: api_token_header(@user)

    assert_response :not_found
  end

  test "should add album to recently played" do
    assert_difference -> { @user.reload.recently_played_albums.count } do
      put api_v1_current_playlist_album_url(albums(:album1)), as: :json, headers: api_token_header(@user)
    end
  end
end
