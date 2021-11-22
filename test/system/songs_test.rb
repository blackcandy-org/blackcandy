# frozen_string_literal: true

require "application_system_test_case"

class SongsSystemTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::VARS[:items] * 2).times do |n|
      Song.create(
        name: "song_test_#{n}",
        file_path: Rails.root.join("test/fixtures/files/artist1_album2.mp3"),
        md5_hash: "fake_md5",
        artist_id: artists(:artist1).id,
        album_id: albums(:album1).id
      )
    end

    login_as users(:visitor1)
  end

  test "show songs" do
    visit songs_url

    assert_selector("#test-main-content .c-tab__item.is-active a", text: "Songs")
    assert_selector("#turbo-songs-content > .o-grid", count: Pagy::VARS[:items])
  end

  test "show next page songs when scroll to the bottom" do
    visit songs_url
    find("#test-main-content").scroll_to :bottom

    assert_selector("#turbo-songs-content > .o-grid", count: Pagy::VARS[:items] * 2)
  end

  test "play song from songs list" do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    visit songs_url

    first_song_element = find("#turbo-songs-content > .o-grid:first-child")
    first_song_name = first_song_element.find(".test-song-name").text
    first_song_element.click

    # when click song to play, the current playlist and player sould list current playing song
    assert_selector("#turbo-playlist .c-list .c-list__item:first-child", text: first_song_name)
    assert_selector(".c-player__header__content", text: first_song_name)
  end

  test "add song to playlist" do
    Playlist.create(name: "test-playlist", user_id: users(:visitor1).id)
    visit songs_url

    first_song_element = find("#turbo-songs-content > .o-grid:first-child")
    first_song_name = first_song_element.find(".test-song-name").text

    first_song_element.find(".test-add-playlist").click
    assert_selector("#turbo-dialog .c-dialog", visible: true)

    find("#turbo-dialog-playlists > form:first-child").click
    # assert the song added to the playlist
    assert_selector("#turbo-playlist .c-list .c-list__item:first-child", text: first_song_name)
  end
end
