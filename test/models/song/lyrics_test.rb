# frozen_string_literal: true

require "test_helper"

class Song::LyricsTest < ActiveSupport::TestCase
  test "should attach lyrics from lyrics file" do
    song = songs(:mp3_sample)

    assert song.lyrics.attach(io: file_fixture("sample.lrc").open, filename: "sample.lrc", content_type: "text/plain")
    assert song.lyrics.attached?
    assert_equal "sample.lrc", song.lyrics.filename.to_s
    assert_equal "text/plain", song.lyrics.content_type
    assert_includes song.lyrics.download, "First line of lyrics"
  end

  test "should replace attached lyrics with new lyrics file" do
    song = songs(:mp3_sample)
    song.lyrics.attach(io: StringIO.new("old lyrics"), filename: "old.lrc", content_type: "text/plain")

    song.lyrics.attach(io: file_fixture("sample.lrc").open, filename: "sample.lrc", content_type: "text/plain")

    assert_includes song.lyrics.download, "First line of lyrics"
  end

  test "should get error when lyrics file format is invalid" do
    song = songs(:mp3_sample)

    assert_not song.lyrics.attach(io: file_fixture("cover_image.jpg").open, filename: "cover_image.jpg", content_type: "image/jpeg")
    assert song.errors[:lyrics].present?
  end

  test "should get error when lyrics file is too large" do
    song = songs(:mp3_sample)

    assert_not song.lyrics.attach(io: StringIO.new("a" * (Song::LYRICS_FILE_MAX_SIZE + 1)), filename: "sample.lrc", content_type: "text/plain")
    assert song.errors[:lyrics].present?
  end

  test "should get external lyrics file path of song" do
    with_external_lyrics_file("external lyrics") do |song, lyrics_file_path|
      assert_equal lyrics_file_path, song.external_lyrics_file_path
    end
  end

  test "should get external lyrics file path from lrc file with uppercase extension" do
    with_external_lyrics_file("external lyrics", extension: ".LRC") do |song, lyrics_file_path|
      assert_equal lyrics_file_path, song.external_lyrics_file_path
    end
  end

  test "should get nil external lyrics file path when song has no external lyrics file" do
    assert_nil songs(:mp3_sample).external_lyrics_file_path
  end
end
