# frozen_string_literal: true

require "test_helper"

class SongTest < ActiveSupport::TestCase
  test "should get file format" do
    assert_equal "mp3", songs(:mp3_sample).format
    assert_equal "flac", songs(:flac_sample).format
    assert_equal "ogg", songs(:ogg_sample).format
    assert_equal "wav", songs(:wav_sample).format
    assert_equal "opus", songs(:opus_sample).format
    assert_equal "m4a", songs(:m4a_sample).format
  end

  test "should remove relative cache files when destroyed" do
    stream = Stream.new(songs(:flac_sample))
    FileUtils.touch(stream.transcode_cache_file_path)
    assert File.exist?(stream.transcode_cache_file_path)

    songs(:flac_sample).destroy
    assert_not File.exist?(stream.transcode_cache_file_path)
  end

  test "should filter by album genre" do
    song_ids = Song.where(album: [albums(:album1), albums(:album2)]).ids.sort
    assert_equal song_ids, Song.filter_records(album_genre: "Rock").ids.sort
  end

  test "should filter by album year" do
    song_ids = Song.where(album: albums(:album1)).ids.sort
    assert_equal song_ids, Song.filter_records(album_year: 1984).ids.sort
  end

  test "should filter by multiple attributes" do
    song_ids = Song.where(album: albums(:album1)).ids.sort
    assert_equal song_ids, Song.filter_records(album_genre: "Rock", album_year: 1984).ids.sort
  end

  test "should have valid filter constant" do
    assert_equal %w[album_genre album_year], Song::VALID_FILTERS
  end

  test "should not filter by invalid filter value" do
    assert_equal Song.all.ids.sort, Song.filter_records(invalid: "test").ids.sort
  end

  test "should sort by name" do
    assert_equal songs(:flac_sample), Song.sort_records(:name).first
    assert_equal songs(:wma_sample), Song.sort_records(:name, :desc).first
  end

  test "should sort by created_at" do
    assert_equal songs(:flac_sample), Song.sort_records(:created_at).first
    assert_equal songs(:wma_sample), Song.sort_records(:created_at, :desc).first
  end

  test "should sort by artist name" do
    assert_equal songs(:mp3_sample), Song.sort_records(:artist_name).first
    assert_equal songs(:ogg_sample), Song.sort_records(:artist_name, :desc).first
  end

  test "should sort by album name" do
    assert_equal songs(:flac_sample), Song.sort_records(:album_name).first
    assert_equal songs(:various_artists_sample), Song.sort_records(:album_name, :desc).first
  end

  test "should sort by album year" do
    assert_equal songs(:various_artists_sample).name, Song.sort_records(:album_year).first.name
    assert_equal songs(:mp3_sample), Song.sort_records(:album_year, :desc).first
  end

  test "should sort by name by default" do
    assert_equal songs(:flac_sample), Song.sort_records.first
  end

  test "should get sort options" do
    assert_equal %w[name created_at artist_name album_name album_year], Song::SORT_OPTION.values
    assert_equal "name", Song::SORT_OPTION.default.name
    assert_equal "asc", Song::SORT_OPTION.default.direction
  end

  test "should use default sort when use invalid sort value" do
    assert_equal songs(:flac_sample), Song.sort_records(:invalid).first
  end

  test "should get unique error when create song with same md5_hash" do
    song = Song.new(
      name: "song_test",
      file_path: Rails.root.join("test/fixtures/files/artist1_album2.mp3"),
      file_path_hash: "fake_path_hash",
      md5_hash: songs(:flac_sample).md5_hash,
      artist_id: artists(:artist1).id,
      album_id: albums(:album1).id
    )

    assert_raise ActiveRecord::RecordNotUnique do
      song.save
    end
  end
end
