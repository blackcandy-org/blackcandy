# frozen_string_literal: true

require 'test_helper'

class CurrentPlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  test 'should show current playlist songs' do
    assert_login_access(url: current_playlist_songs_url, xhr: true) do
      assert_response :success
    end
  end
end
