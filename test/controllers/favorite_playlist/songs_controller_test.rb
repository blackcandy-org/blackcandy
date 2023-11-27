# frozen_string_literal: true

require "test_helper"

class FavoritePlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  test "should show favorite playlist songs" do
    login
    get favorite_playlist_songs_url

    assert_response :success
  end
end
