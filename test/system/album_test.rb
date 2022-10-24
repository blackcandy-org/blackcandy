# frozen_string_literal: true

require "application_system_test_case"

class AlbumSystemTest < ApplicationSystemTestCase
  setup do
    @album = albums(:album1)
  end

  test "show album" do
    login_as users(:visitor1)
    visit album_url(@album)

    assert_text(@album.name)
    assert_text(@album.artist.name)

    @album.songs.each do |song|
      assert_text(song.name)
    end
  end

  test "play all songs on album" do
    login_as users(:visitor1)
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))

    visit album_url(@album)
    click_on "Play all"

    # assert current playlist have all songs in album
    @album.songs.each do |song|
      assert_selector(:test_id, "playlist_song_name", text: song.name)
    end

    # assert play the first song in album
    assert_selector(:test_id, "player_song_name", text: @album.songs.first.name)
  end

  test "edit album" do
    login_as users(:admin)

    visit album_url(@album)

    album_original_image_url = find(:test_id, "album_image")[:src]

    click_on "Edit"
    assert_selector(:test_id, "album_edit_form", visible: true)

    attach_file("album_image", fixtures_file_path("cover_image.jpg"))
    click_on "Save"

    assert_text("Updated successfully")
    assert_not_equal album_original_image_url, find(:test_id, "album_image")[:src]
  end

  test "play song from album" do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    login_as users(:visitor1)

    visit album_url(@album)

    first_song_name = first(:test_id, "album_song_name").text
    first(:test_id, "album_song").click

    # when click song to play, the current playlist and player sould list current playing song
    assert_equal first_song_name, first(:test_id, "playlist_song_name").text
    assert_selector(:test_id, "player_song_name", text: first_song_name)
  end

  test "add song to playlist" do
    playlist = Playlist.create(name: "test-playlist", user_id: users(:visitor1).id)
    login_as users(:visitor1)

    visit album_url(@album)

    first_song_name = first(:test_id, "album_song_name").text

    first(:test_id, "album_song_add_playlist").click
    first(:test_id, "dialog_playlist").click

    # assert the song added to the playlist
    assert_equal first_song_name, playlist.songs.first.name
  end
end
