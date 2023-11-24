# frozen_string_literal: true

require "test_helper"

class Playlists::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:playlist1)
    @user = @playlist.user

    login @user
  end

  test "should show playlist songs" do
    get playlist_songs_url(@playlist)
    assert_response :success
  end

  test "should add songs to playlist" do
    post playlist_songs_url(@playlist), params: {song_id: 3}, xhr: true
    assert_equal [1, 2, 3], @playlist.reload.song_ids
  end

  test "should remove songs from playlist" do
    delete playlist_song_url(@playlist, id: 1), xhr: true
    assert_equal [2], @playlist.reload.song_ids

    delete playlist_song_url(@playlist, id: 2), xhr: true
    assert_equal [], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist" do
    delete playlist_songs_url(@playlist)
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist" do
    post playlist_songs_url(@playlist), params: {song_id: 3}, xhr: true
    assert_equal [1, 2, 3], @playlist.reload.song_ids

    put move_playlist_song_url(@playlist, id: 1), params: {destination_song_id: 2}

    assert_response :success
    assert_equal [2, 1, 3], @playlist.reload.song_ids

    put move_playlist_song_url(@playlist, id: 3), params: {destination_song_id: 2}
    assert_response :success
    assert_equal [3, 2, 1], @playlist.reload.song_ids
  end

  test "should return not found when reorder song not in playlist" do
    put move_playlist_song_url(@playlist, id: 4), params: {destination_song_id: 2}
    assert_response :not_found
  end

  test "should has error flash when song alreay in playlist" do
    post playlist_songs_url(@playlist), params: {song_id: 1}, xhr: true
    assert flash[:error].present?
  end
end
