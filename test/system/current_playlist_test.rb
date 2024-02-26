# frozen_string_literal: true

require "application_system_test_case"

class CurrentPlaylistSystemTest < ApplicationSystemTestCase
  setup do
    users(:visitor1).current_playlist.replace(Song.ids.sort)
    login_as users(:visitor1)
  end

  test "show playlist songs" do
    assert_selector(:test_id, "current_playlist_song", count: Song.count)

    Song.all.each do |song|
      assert_selector(:test_id, "current_playlist_song_name", text: song.name)
    end
  end

  test "clear playlist songs" do
    find(:test_id, "playlist_menu").click
    click_on "Clear"

    assert_selector(:test_id, "current_playlist_song", count: 0)
    assert_text("No Items")
  end

  test "player is stopped after clear current playlist" do
    find(:test_id, "playlist_menu").click
    click_on "Clear"

    find(:test_id, "player_next_button").click
    assert_selector(:test_id, "player_header", visible: false)
  end

  test "play song in playlist" do
    first(:test_id, "current_playlist_song").click

    assert_selector(:test_id, "player_header", visible: true)
    assert_selector(:test_id, "player_song_name", text: Song.first.name)
  end

  test "delete song in playlist" do
    first(:test_id, "current_playlist_song_menu").click
    click_on "Delete"

    assert_selector(:test_id, "current_playlist_song", count: Song.count - 1)
  end

  # Temporarily disable this test, because cuprite does not support HTML drag and drop event,
  # so need to switch to another driver to test this feature.
  # test "reorder song in playlist" do
  #   source_element = first(:test_id, "playlist_song_sortable_handle")
  #   target_element = all(:test_id, "playlist_song_sortable_handle").last
  #   source_element.drag_to(target_element)
  #
  #   assert_equal Song.first.name, all(:test_id, "current_playlist_song_name").last.text
  # end

  test "add to playlist" do
    playlist_name = "test-playlist"
    playlist = Playlist.create(name: playlist_name, user_id: users(:visitor1).id)

    assert_difference -> { playlist.songs.count } do
      first(:test_id, "current_playlist_song_menu").click
      click_on "Add To Playlist"
      find(:test_id, "dialog_playlist", text: playlist_name).click
    end
  end
end
