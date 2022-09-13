require "test_helper"

class Api::V1::CurrentPlaylist::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @user.current_playlist.song_ids = [1, 2]
  end

  test "should show all songs" do
    get api_v1_current_playlist_songs_url, as: :json, headers: api_token_header(@user)
    response = @response.parsed_body

    assert_response :success
    assert_equal [1, 2], response.map { |song| song["id"] }
  end
end
