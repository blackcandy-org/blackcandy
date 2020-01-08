# frozen_string_literal: true

require 'test_helper'

class FavoritePlaylistsControllerTest < ActionDispatch::IntegrationTest
  test 'should show favorite playlist' do
    assert_login_access(url: favorite_playlist_url, xhr: true) do
      assert_response :success
    end
  end
end
