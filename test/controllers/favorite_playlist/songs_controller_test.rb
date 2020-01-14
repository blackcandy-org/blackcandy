# frozen_string_literal: true

require 'test_helper'

class FavoritePlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  test 'should show favorite playlist songs' do
    assert_login_access(url: favorite_playlist_songs_url, xhr: true) do
      assert_response :success
    end
  end
end
