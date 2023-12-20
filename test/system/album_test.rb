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

    visit album_url(@album)
    click_on "Play all"

    # assert current playlist have all songs in album
    @album.songs.each do |song|
      assert_selector(:test_id, "current_playlist_song_name", text: song.name)
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
    login_as users(:visitor1)

    visit album_url(@album)

    first_song_name = first(:test_id, "album_song_name").text
    first(:test_id, "album_song").click

    # when click song to play, the current playlist and player sould list current playing song
    assert_equal first(:test_id, "current_playlist_song_name").text, first_song_name
    assert_selector(:test_id, "player_song_name", text: first_song_name)
  end

  test "add song to playlist" do
    playlist_name = "test-playlist"
    playlist = Playlist.create(name: playlist_name, user_id: users(:visitor1).id)
    login_as users(:visitor1)

    visit album_url(@album)
    first(:test_id, "album_song_menu").click
    click_on "Add to playlist"
    find(:test_id, "dialog_playlist", text: playlist_name).click

    # assert the song added to the playlist
    assert_equal playlist.songs.first.name, first(:test_id, "album_song_name").text
  end

  test "add song to the next in current playlist" do
    login_as users(:visitor1)
    visit album_url(@album)

    first(:test_id, "album_song_menu").click
    click_on "Play Next"
    assert_equal first(:test_id, "current_playlist_song_name").text, first(:test_id, "album_song_name").text

    find("body").click
    first(:test_id, "current_playlist_song").click
    all(:test_id, "album_song_menu").last.click
    click_on "Play Next"
    assert_equal all(:test_id, "current_playlist_song_name")[1].text, all(:test_id, "album_song_name").last.text
  end

  test "add song to the end in current playlist" do
    song_ids = Song.ids - @album.songs.ids
    users(:visitor1).current_playlist.replace(song_ids)
    login_as users(:visitor1)
    visit album_url(@album)

    first(:test_id, "album_song_menu").click
    click_on "Play Last"

    assert_equal all(:test_id, "current_playlist_song_name").last.text, first(:test_id, "album_song_name").text
  end
end
