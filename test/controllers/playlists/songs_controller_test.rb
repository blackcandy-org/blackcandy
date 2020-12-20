# frozen_string_literal: true

require 'test_helper'

class Playlists::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:playlist1)
    @user = @playlist.user
  end

  test 'should show playlist songs' do
    assert_login_access(user: @user, url: playlist_songs_url(@playlist), xhr: true) do
      assert_response :success
    end
  end

  test 'should add songs to playlist' do
    assert_login_access(
      user: @user,
      method: :post,
      url: playlist_songs_url(@playlist),
      params: { song_ids: [3] },
      xhr: true
    ) do
      assert_equal [1, 2, 3], @playlist.reload.song_ids
    end

    assert_login_access(
      user: @user,
      method: :post,
      url: playlist_songs_url(@playlist),
      params: { song_ids: [4, 5] },
      xhr: true
    ) do
      assert_equal [1, 2, 3, 4, 5], @playlist.reload.song_ids
    end
  end

  test 'should remove songs from playlist' do
    assert_login_access(
      user: @user,
      method: :delete,
      url: playlist_songs_url(@playlist),
      params: { song_ids: [1] },
      xhr: true
    ) do
      assert_equal [2], @playlist.reload.song_ids
    end

    assert_login_access(
      user: @user,
      method: :delete,
      url: playlist_songs_url(@playlist),
      params: { song_ids: [2, 3] },
      xhr: true
    ) do
      assert_equal [], @playlist.reload.song_ids
    end
  end

  test 'should clear all songs from playlist' do
    assert_login_access(
      user: @user,
      method: :delete,
      url: playlist_songs_url(@playlist),
      params: { clear_all: true },
      xhr: true
    ) do
      assert_equal [], @playlist.reload.song_ids
    end
  end

  test 'should reorder songs from playlist' do
    assert_equal [1, 2], @playlist.song_ids

    assert_login_access(
      user: @user,
      method: :put,
      url: playlist_songs_url(@playlist),
      params: { from_position: 1, to_position: 2 },
      xhr: true
    ) do
      assert_equal [2, 1], @playlist.reload.song_ids
    end
  end

  test 'should play whole playlist' do
    assert_not_equal @playlist.song_ids, @user.current_playlist.song_ids

    assert_login_access(
      user: @user,
      method: :post,
      url: play_playlist_songs_url(@playlist),
      xhr: true
    ) do
      assert_equal @playlist.song_ids, @user.current_playlist.reload.song_ids
    end
  end
end
