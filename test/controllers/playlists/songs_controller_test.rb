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
    assert_equal [3, 1, 2], @playlist.reload.song_ids
  end

  test "should remove songs from playlist" do
    delete playlist_songs_url(@playlist), params: {song_id: 1}, xhr: true
    assert_equal [2], @playlist.reload.song_ids

    delete playlist_songs_url(@playlist), params: {song_id: 2}, xhr: true
    assert_equal [], @playlist.reload.song_ids
  end

  test "should clear all songs from playlist" do
    delete playlist_songs_url(@playlist), params: {clear_all: true}
    assert_equal [], @playlist.reload.song_ids
  end

  test "should reorder songs from playlist" do
    assert_equal [1, 2], @playlist.song_ids

    put playlist_songs_url(@playlist), params: {from_position: 1, to_position: 2}

    assert_equal [2, 1], @playlist.reload.song_ids
  end

  test "should play whole playlist" do
    assert_not_equal @playlist.song_ids, @user.current_playlist.song_ids

    post play_playlist_songs_url(@playlist)

    assert_equal @playlist.song_ids, @user.current_playlist.reload.song_ids
  end
end
