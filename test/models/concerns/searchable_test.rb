# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  test "should have search class method when declared search_by on class" do
    assert_respond_to Album, :search
    assert_respond_to Artist, :search
    assert_respond_to Song, :search
  end

  test "should support search by model attribute" do
    assert_equal Artist.where(name: %w[artist1]).ids.sort, Artist.search("artist1").ids.sort
  end

  test "should support fuzzy search by model attribute" do
    assert_equal Artist.where(name: %w[artist1 artist2 various_artists]).ids.sort, Artist.search("artist").ids.sort
  end

  test "should support search by model attribute with association" do
    assert_equal Artist.find_by(name: "artist1").albums.ids.sort, Album.search("artist1").ids.sort
  end

  test "should support fuzzy search by model attribute with association" do
    album_ids = Artist.find_by(name: "artist1").albums.ids +
      Artist.find_by(name: "artist2").albums.ids +
      Artist.find_by(name: "various_artists").albums.ids

    assert_equal album_ids.sort, Album.search("artist").ids.sort
  end

  test "should support search by model attribute with multiple associations" do
    assert_equal Artist.find_by(name: "artist1").songs.ids.sort, Song.search("artist1").ids.sort
    assert_equal Album.find_by(name: "album1").songs.ids.sort, Song.search("album1").ids.sort
  end

  test "should support fuzzy search by model attribute with multiple associations" do
    artist_serach_song_ids = Artist.find_by(name: "artist1").songs.ids +
      Artist.find_by(name: "artist2").songs.ids
    assert_equal artist_serach_song_ids.sort, Song.search("artist").ids.sort

    album_serach_song_ids = Album.find_by(name: "album1").songs.ids +
      Album.find_by(name: "album2").songs.ids +
      Album.find_by(name: "album3").songs.ids +
      Album.find_by(name: "album4").songs.ids

    assert_equal album_serach_song_ids.sort, Song.search("album").ids.sort
  end
end
