# frozen_string_literal: true

require "application_system_test_case"

class FavoritePlaylistSystemTest < ApplicationSystemTestCase
  setup do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    users(:visitor1).favorite_playlist.replace(Song.ids)
    login_as users(:visitor1)

    click_on "Favorites"
  end

  test "show playlist songs" do
    assert_selector(:test_id, "playlist_song", count: Song.count)

    Song.all.each do |song|
      assert_selector(:test_id, "playlist_song_name", text: song.name)
    end
  end

  test "play all songs in playlist" do
    find(:test_id, "playlist_menu").click
    click_on "Play all"

    # assert current playlist have all songs in playlist
    assert_selector(:test_id, "current_playlist", visible: true)
    Song.all.each.each do |song|
      assert_selector(:test_id, "playlist_song_name", text: song.name)
    end

    # assert play the first song in playlist
    assert_selector(:test_id, "player_song_name", text: Song.first.name)
  end

  test "clear playlist songs" do
    find(:test_id, "playlist_menu").click
    click_on "Clear"

    assert_selector(:test_id, "playlist_song", count: 0)
    assert_text("No items")
  end

  test "play song in playlist" do
    first(:test_id, "playlist_song").click

    assert_selector(:test_id, "player_header", visible: true)
    assert_selector(:test_id, "player_song_name", text: Song.first.name)
  end

  test "delete song in playlist" do
    first(:test_id, "playlist_song_menu").click
    click_on "Delete"

    assert_selector(:test_id, "playlist_song", count: Song.count - 1)
  end

  test "reorder song in playlist" do
    source_element = first(:test_id, "playlist_song_sortable_handle")
    target_element = all(:test_id, "playlist_song_sortable_handle").last

    source_element.drag_to(target_element)

    assert_equal Song.first.name, all(:test_id, "playlist_song_name").last.text
  end

  test "add to playlist" do
    Playlist.create(name: "test-playlist", user_id: users(:visitor1).id)

    first(:test_id, "playlist_song_menu").click
    click_on "Add to playlist"
    first(:test_id, "dialog_playlist").click

    assert_selector(:test_id, "playlist_name", text: "test-playlist")
    assert_equal Song.first.name, first(:test_id, "playlist_song_name").text
  end
end
