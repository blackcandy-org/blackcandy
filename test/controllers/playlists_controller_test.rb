# frozen_string_literal: true

require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get playlists_url

    assert_response :success
  end

  test "should create playlist" do
    playlists_count = Playlist.count

    login
    post playlists_url, params: {playlist: {name: "test"}}, xhr: true

    assert_equal playlists_count + 1, Playlist.count
  end

  test "should has error flash when failed to create playlist" do
    login
    post playlists_url, params: {playlist: {name: ""}}, xhr: true

    assert flash[:error].present?
  end

  test "should update playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    login user
    patch playlist_url(playlist), params: {playlist: {name: "updated_playlist"}}

    assert_equal "updated_playlist", playlist.reload.name
  end

  test "should has error flash when failed to update playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    login user
    patch playlist_url(playlist), params: {playlist: {name: ""}}

    assert flash[:error].present?
  end

  test "should destroy playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user
    playlists_count = Playlist.count

    login user
    delete playlist_url(playlist)

    assert_equal playlists_count - 1, Playlist.count
  end
end
