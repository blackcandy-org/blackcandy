# frozen_string_literal: true

require 'test_helper'

class CurrentPlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  test 'should show current playlist songs' do
    assert_login_access(url: current_playlist_songs_url, xhr: true) do
      assert_response :success
    end
  end

  test 'should update whole playlist songs' do
    assert_login_access(method: :put, url: current_playlist_songs_url(song_ids: [1, 2, 3]), xhr: true) do |user|
      assert_equal [1, 2, 3], user.current_playlist.song_ids
    end
  end
end
