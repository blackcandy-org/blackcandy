# frozen_string_literal: true

require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    assert_login_access(url: playlists_url) do
      assert_response :success
    end
  end

  test "should create playlist" do
    playlists_count = Playlist.count

    assert_login_access(method: :post, url: playlists_url, params: {playlist: {name: "test"}}, xhr: true) do
      assert_equal playlists_count + 1, Playlist.count
    end
  end

  test "should update playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    assert_login_access(
      user: user,
      method: :patch,
      url: playlist_url(playlist),
      params: {playlist: {name: "updated_playlist"}}
    ) do
      assert_equal "updated_playlist", playlist.reload.name
    end
  end

  test "should destroy playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user
    playlists_count = Playlist.count

    assert_login_access(user: user, method: :delete, url: playlist_url(playlist)) do
      assert_equal playlists_count - 1, Playlist.count
    end
  end
end
