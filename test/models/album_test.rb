# frozen_string_literal: true

require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  test "should not have same name album on an artist" do
    artists(:artist1).albums.create(name: "best")
    assert_not artists(:artist1).albums.build(name: "best").valid?
  end

  test "should have default title when name is empty" do
    assert_equal "Unknown Album", Album.create(name: nil).title
  end

  test "should order by tracknum for associated songs" do
    artist = artists(:artist1)
    album = artist.albums.create

    album.songs.create!(
      [
        {name: "test_song_1", file_path: "fake_path", file_path_hash: "fake_path_hash", md5_hash: "fake_md5", tracknum: 2, artist: artist},
        {name: "test_song_2", file_path: "fake_path", file_path_hash: "fake_path_hash", md5_hash: "fake_md5", tracknum: 3, artist: artist},
        {name: "test_song_3", file_path: "fake_path", file_path_hash: "fake_path_hash", md5_hash: "fake_md5", tracknum: 1, artist: artist}
      ]
    )

    assert_equal %w[test_song_3 test_song_1 test_song_2], album.songs.pluck(:name)
  end
end
