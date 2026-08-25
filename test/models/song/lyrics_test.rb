# frozen_string_literal: true

require "test_helper"

class Song::LyricsTest < ActiveSupport::TestCase
  test "should get lyrics lines" do
    song = songs(:mp3_sample)
    song.update!(lyrics: "[00:01.00]first\n[00:02.00]second")

    assert_equal [ 1.0, 2.0 ], song.lyrics_lines.map(&:time)
    assert_equal [ "first", "second" ], song.lyrics_lines.map(&:content)
  end

  test "should get no lyrics lines when song has no lyrics" do
    assert_empty songs(:mp3_sample).lyrics_lines
  end

  test "should get lyrics content from external lyrics file when song has no lyrics" do
    with_external_lyrics_file("[00:01.00]external") do |song|
      assert_equal "[00:01.00]external", song.lyrics_content
      assert_equal [ "external" ], song.lyrics_lines.map(&:content)
    end
  end

  test "should get lyrics content from external lyrics file with uppercase extension" do
    with_external_lyrics_file("[00:01.00]external", extension: ".LRC") do |song|
      assert_equal "[00:01.00]external", song.lyrics_content
    end
  end

  test "should get lyrics content from lyrics column first when song also has external lyrics file" do
    with_external_lyrics_file("[00:01.00]external") do |song|
      song.update!(lyrics: "[00:01.00]saved")

      assert_equal "[00:01.00]saved", song.lyrics_content
    end
  end

  test "should set lyrics from lyrics file" do
    song = songs(:mp3_sample)

    assert song.update(lyrics_file: uploaded_file("sample.lrc"))
    assert_includes song.lyrics, "First line of lyrics"
  end

  test "should get error when lyrics file format is invalid" do
    song = songs(:mp3_sample)

    assert_not song.update(lyrics_file: uploaded_file("cover_image.jpg", content_type: "image/jpeg"))
    assert song.errors[:lyrics_file].present?
  end

  test "should get error when lyrics from lyrics file are too long" do
    song = songs(:mp3_sample)

    create_tmp_file(format: "lrc") do |file_path|
      File.write(file_path, "a" * (Song::LYRICS_MAX_LENGTH + 1))

      assert_not song.update(lyrics_file: Rack::Test::UploadedFile.new(file_path, "text/plain"))
    end

    assert song.errors[:lyrics].present?
  end
end
