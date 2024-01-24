# frozen_string_literal: true

require "test_helper"

class MediaFileTest < ActiveSupport::TestCase
  test "should get file path array from media_path" do
    expect_file_paths = [
      fixtures_file_path("artist1_album1.flac"),
      fixtures_file_path("artist2_album3.ogg"),
      fixtures_file_path("artist1_album2.mp3"),
      fixtures_file_path("artist2_album3.wav"),
      fixtures_file_path("artist2_album3.opus"),
      fixtures_file_path("artist2_album3.wma"),
      fixtures_file_path("artist2_album3.oga"),
      fixtures_file_path("artist1_album1.m4a"),
      fixtures_file_path("various_artists.mp3")
    ]

    MediaFile.file_paths(Rails.root.join("test/fixtures/files")).each do |file_path|
      assert_includes expect_file_paths, file_path
    end
  end

  test "should get file path array from case insensitive files" do
    expect_file_paths = [
      Rails.root.join("test/fixtures/case_insensitive_files", "test.MP3"),
      Rails.root.join("test/fixtures/case_insensitive_files", "test.oGG"),
      Rails.root.join("test/fixtures/case_insensitive_files", "test.FLac"),
      Rails.root.join("test/fixtures/case_insensitive_files", "test.WaV"),
      Rails.root.join("test/fixtures/case_insensitive_files", "test.OpUS")
    ].map(&:to_s)

    MediaFile.file_paths(Rails.root.join("test/fixtures/case_insensitive_files")).each do |file_path|
      assert_includes expect_file_paths, file_path
    end
  end

  test "should ignore not supported files under media_path" do
    assert_not_includes MediaFile.file_paths(Rails.root.join("test/fixtures/files")), fixtures_file_path("not_supported_file.txt")
  end

  test "should get correct format" do
    assert_equal "mp3", MediaFile.format(file_fixture("artist1_album2.mp3"))
    assert_equal "flac", MediaFile.format(file_fixture("artist1_album1.flac"))
    assert_equal "ogg", MediaFile.format(file_fixture("artist2_album3.ogg"))
    assert_equal "wav", MediaFile.format(file_fixture("artist2_album3.wav"))
    assert_equal "opus", MediaFile.format(file_fixture("artist2_album3.opus"))
    assert_equal "oga", MediaFile.format(file_fixture("artist2_album3.oga"))
    assert_equal "wma", MediaFile.format(file_fixture("artist2_album3.wma"))
    assert_equal "m4a", MediaFile.format(file_fixture("artist1_album1.m4a"))
  end

  test "should get tag info from mp3 file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist1_album2.mp3"))
    tag_image_binary = tag_info[:image][:io].read.force_encoding("BINARY").strip
    cover_image_binary = file_fixture("cover_image.jpg").read.force_encoding("BINARY").strip

    assert_equal "mp3_sample", tag_info[:name]
    assert_equal "album2", tag_info[:album_name]
    assert_equal "artist1", tag_info[:artist_name]
    assert_equal "artist1", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_equal cover_image_binary, tag_image_binary
    assert_equal 0, tag_info[:discnum]
  end

  test "should get tag info from flac file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist1_album1.flac"))
    tag_image_binary = tag_info[:image][:io].read.force_encoding("BINARY").strip
    cover_image_binary = file_fixture("cover_image.jpg").read.force_encoding("BINARY").strip

    assert_equal "flac_sample", tag_info[:name]
    assert_equal "album1", tag_info[:album_name]
    assert_equal "artist1", tag_info[:artist_name]
    assert_equal "artist1", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_equal cover_image_binary, tag_image_binary
    assert_equal 0, tag_info[:discnum]
  end

  test "should get tag info from ogg file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist2_album3.ogg"))

    assert_equal "ogg_sample", tag_info[:name]
    assert_equal "album3", tag_info[:album_name]
    assert_equal "artist2", tag_info[:artist_name]
    assert_equal "artist2", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_nil tag_info[:discnum]
  end

  test "should get tag info from wav file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist2_album3.wav"))
    tag_image_binary = tag_info[:image][:io].read.force_encoding("BINARY").strip
    cover_image_binary = file_fixture("cover_image.jpg").read.force_encoding("BINARY").strip

    assert_equal "wav_sample", tag_info[:name]
    assert_equal "album3", tag_info[:album_name]
    assert_equal "artist2", tag_info[:artist_name]
    assert_equal "artist2", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_equal cover_image_binary, tag_image_binary
    assert_equal 0, tag_info[:discnum]
  end

  test "should get tag info from opus file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist2_album3.opus"))

    assert_equal "opus_sample", tag_info[:name]
    assert_equal "album3", tag_info[:album_name]
    assert_equal "artist2", tag_info[:artist_name]
    assert_equal "artist2", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_nil tag_info[:discnum]
  end

  test "should get tag info from m4a file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist1_album1.m4a"))
    tag_image_binary = tag_info[:image][:io].read.force_encoding("BINARY").strip
    cover_image_binary = file_fixture("cover_image.jpg").read.force_encoding("BINARY").strip

    assert_equal "m4a_sample", tag_info[:name]
    assert_equal "album1", tag_info[:album_name]
    assert_equal "artist1", tag_info[:artist_name]
    assert_equal "artist1", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_equal cover_image_binary, tag_image_binary
    assert_nil tag_info[:discnum]
  end

  test "should get tag info from oga file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist2_album3.oga"))

    assert_equal "oga_sample", tag_info[:name]
    assert_equal "album3", tag_info[:album_name]
    assert_equal "artist2", tag_info[:artist_name]
    assert_equal "artist2", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_equal 1984, tag_info[:year]
    assert_equal "Rock", tag_info[:genre]
    assert_nil tag_info[:discnum]
  end

  test "should get tag info from wma file" do
    tag_info = MediaFile.send(:get_tag_info, file_fixture("artist2_album3.wma"))

    assert_equal "wma_sample", tag_info[:name]
    assert_equal "album3", tag_info[:album_name]
    assert_equal "artist2", tag_info[:artist_name]
    assert_equal "artist2", tag_info[:albumartist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:duration]
    assert_nil tag_info[:year]
    assert_nil tag_info[:genre]
    assert_nil tag_info[:discnum]
  end

  test "should get md5 hash from file" do
    assert_not MediaFile.file_info(file_fixture("artist1_album2.mp3"))[:md5_hash].blank?
  end

  test "should raise error from file_info when file is not exist" do
    assert_raises(StandardError) do
      MediaFile.file_info("/not_exist")
    end
  end

  test "should normalize image mime type" do
    tag = WahWah.open(file_fixture("artist2_album3.wav"))

    assert_equal "image/jpg", tag.images.first[:mime_type]
    assert_equal "image/jpeg", MediaFile.file_info(file_fixture("artist2_album3.wav"))[:image][:content_type]
  end
end
