# frozen_string_literal: true

require 'test_helper'

class CurrentPlaylistSongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @playlist = @user.current_playlist
    @playlist.song_ids = [1, 2]
  end

  test 'should show current playlist songs' do
    assert_login_access(url: current_playlist_songs_url) do
      assert_response :success
    end
  end

  test 'should add song next to the current song when current song did set' do
    cookies[:current_song_id] = @playlist.song_ids.first

    assert_login_access(
      user: @user,
      method: :post,
      url: current_playlist_songs_url,
      params: { song_id: 3 },
      xhr: true
    ) do
      assert_equal [1, 3, 2], @playlist.reload.song_ids
    end
  end

  test 'should add song to the first position when current song did not set' do
    assert_login_access(
      user: @user,
      method: :post,
      url: current_playlist_songs_url,
      params: { song_id: 3 },
      xhr: true
    ) do
      assert_equal [3, 1, 2], @playlist.reload.song_ids
    end
  end
end
