# frozen_string_literal: true

require "application_system_test_case"

class SongsSystemTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::DEFAULT[:items] * 2).times do |n|
      Song.create(
        name: "song_test_#{n}",
        file_path: Rails.root.join("test/fixtures/files/artist1_album2.mp3"),
        file_path_hash: "fake_path_hash",
        md5_hash: "fake_md5",
        artist_id: artists(:artist1).id,
        album_id: albums(:album1).id
      )
    end

    login_as users(:visitor1)
  end

  test "show songs" do
    visit songs_url

    assert_selector(:test_id, "song_item", count: Pagy::DEFAULT[:items])
  end

  test "show next page songs when scroll to the bottom" do
    visit songs_url
    scroll_to :bottom

    assert_selector(:test_id, "song_item", count: Pagy::DEFAULT[:items] * 2)
  end

  test "play song from songs list" do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    visit songs_url

    first_song_name = first(:test_id, "song_name").text
    first(:test_id, "song_item").click

    # when click song to play, the current playlist and player sould list current playing song
    assert_equal first_song_name, first(:test_id, "playlist_song_name").text
    assert_selector(:test_id, "player_song_name", text: first_song_name)
  end

  test "add song to playlist" do
    Playlist.create(name: "test-playlist", user_id: users(:visitor1).id)
    visit songs_url

    first_song_name = first(:test_id, "song_name").text

    first(:test_id, "song_add_playlist").click
    first(:test_id, "dialog_playlist").click

    # assert the song added to the playlist
    assert_equal first_song_name, first(:test_id, "playlist_song_name").text
  end
end
