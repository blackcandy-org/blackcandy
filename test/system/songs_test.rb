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

    assert_selector(:test_id, "song_item", count: Pagy::DEFAULT[:items], visible: :all)
  end

  test "show next page songs when scroll to the bottom" do
    visit songs_url
    scroll_to :bottom

    assert_selector(:test_id, "song_item", count: Pagy::DEFAULT[:items] * 2, visible: :all)
  end

  test "play song from songs list" do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    visit songs_url

    first_song_name = first(:test_id, "song_name").text
    first(:test_id, "song_item").click

    # when click song to play, the current playlist and player sould list current playing song
    assert_equal first_song_name, first(:test_id, "current_playlist_song_name").text
    assert_selector(:test_id, "player_song_name", text: first_song_name)
  end

  test "add song to playlist" do
    playlist_name = "test-playlist"
    playlist = Playlist.create(name: playlist_name, user_id: users(:visitor1).id)

    visit songs_url
    first(:test_id, "song_menu").click
    click_on "Add to playlist"
    find(:test_id, "dialog_playlist", text: playlist_name).click

    # assert the song added to the playlist
    assert_equal playlist.songs.first.name, first(:test_id, "song_name").text
  end

  test "add song to the next in current playlist" do
    visit songs_url

    first(:test_id, "song_menu").click
    click_on "Play Next"
    assert_equal first(:test_id, "current_playlist_song_name").text, first(:test_id, "song_name").text

    find("body").click
    first(:test_id, "current_playlist_song").click
    all(:test_id, "song_menu")[1].click
    click_on "Play Next"
    assert_equal all(:test_id, "current_playlist_song_name")[1].text, all(:test_id, "song_name")[1].text
  end

  test "add song to the end in current playlist" do
    visit songs_url

    first(:test_id, "song_menu").click
    click_on "Play Last"
    assert_equal all(:test_id, "current_playlist_song_name").last.text, first(:test_id, "song_name").text

    find("body").click
    all(:test_id, "song_menu")[1].click
    click_on "Play Last"
    assert_equal all(:test_id, "current_playlist_song_name").last.text, all(:test_id, "song_name")[1].text
  end
end
