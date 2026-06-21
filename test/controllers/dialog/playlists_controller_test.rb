# frozen_string_literal: true

require "test_helper"

class Dialog::PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get dialog_playlists_url(song_id: songs(:mp3_sample).id)

    assert_response :success
    assert_select "form[action='#{playlists_path}']"
    assert_select "input[name='song_id'][value='#{songs(:mp3_sample).id}']"
  end

  test "should get new playlist" do
    login
    get new_dialog_playlist_path

    assert_response :success
  end

  test "should edit playlist" do
    playlist = playlists(:playlist1)
    user = playlist.user

    login user
    get edit_dialog_playlist_path(playlist)

    assert_response :success
  end
end
