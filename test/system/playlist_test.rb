# frozen_string_literal: true

require "application_system_test_case"

class PlaylistSystemTest < ApplicationSystemTestCase
  setup do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    login_as users(:admin)

    visit playlist_songs_url(playlists(:playlist1))
  end

  test "show playlist songs" do
    playlists(:playlist1).songs.each do |song|
      assert_selector(:test_id, "playlist_song_name", text: song.name)
    end
  end

  test "play all songs in playlist" do
    click_on "Play all"

    # assert current playlist have all songs in playlist
    assert_selector(:test_id, "current_playlist", visible: true)
    playlists(:playlist1).songs.each do |song|
      assert_selector(:test_id, "current_playlist_song_name", text: song.name)
    end

    # assert play the first song in playlist
    assert_selector(:test_id, "player_song_name", text: Song.first.name)
  end

  test "clear playlist songs" do
    find(:test_id, "playlist_menu").click
    click_on "Clear"

    assert_selector(:test_id, "playlist_song", count: 0)
  end

  test "delete playlist" do
    playlist_count = users(:admin).all_playlists.count

    find(:test_id, "playlist_menu").click
    click_on "Delete"

    assert_selector(:test_id, "playlist", count: playlist_count - 1)
  end

  test "edit playlist" do
    click_on "Edit"

    assert_selector(:test_id, "playlist_edit_form", visible: true)

    fill_in "playlist_name", with: "renamed_playlist"
    click_on "Save"

    assert_text("Updated successfully")
    assert_selector(:test_id, "playlist_name", text: "renamed_playlist")
  end

  test "delete song in playlist" do
    playlist_songs_count = playlists(:playlist1).songs.count

    first(:test_id, "playlist_song_menu").click
    click_on "Delete"

    assert_selector(:test_id, "playlist_song", count: playlist_songs_count - 1)
  end

  # Temporarily disable this test, because cuprite does not support HTML drag and drop event,
  # so need to switch to another driver to test this feature.
  # test "reorder song in playlist" do
  #   first_playlist_song_name = playlists(:playlist1).songs.first.name
  #   source_element = first(:test_id, "playlist_song_sortable_handle")
  #   target_element = all(:test_id, "playlist_song_sortable_handle").last
  #
  #   source_element.drag_to(target_element)
  #
  #   assert_equal first_playlist_song_name, all(:test_id, "playlist_song_name").last.text
  # end

  test "play song in playlist" do
    first(:test_id, "playlist_song").click

    assert_selector(:test_id, "player_header", visible: true)
    assert_selector(:test_id, "player_song_name", text: playlists(:playlist1).songs.first.name)
  end

  test "add song to another playlist" do
    playlist_name = "test-playlist"
    playlist = Playlist.create(name: playlist_name, user_id: users(:admin).id)

    first(:test_id, "playlist_song_menu").click
    click_on "Add to playlist"
    find(:test_id, "dialog_playlist", text: playlist_name).click

    assert_equal playlists(:playlist1).songs.first.name, playlist.songs.first.name
  end

  test "add song to the next in current playlist" do
    first(:test_id, "playlist_song_menu").click
    click_on "Play Next"
    assert_equal first(:test_id, "current_playlist_song_name").text, playlists(:playlist1).songs.first.name

    find("body").click
    first(:test_id, "current_playlist_song").click
    all(:test_id, "playlist_song_menu").last.click
    click_on "Play Next"
    assert_equal all(:test_id, "current_playlist_song_name")[1].text, playlists(:playlist1).songs.last.name
  end

  test "add song to the end in current playlist" do
    song_ids = Song.ids - playlists(:playlist1).songs.ids
    users(:admin).current_playlist.replace(song_ids)
    visit playlist_songs_url(playlists(:playlist1))

    first(:test_id, "playlist_song_menu").click
    click_on "Play Last"

    assert_equal all(:test_id, "current_playlist_song_name").last.text, playlists(:playlist1).songs.first.name
  end
end
