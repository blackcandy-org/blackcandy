# frozen_string_literal: true

require "test_helper"

class Songs::LyricsControllerTest < ActionDispatch::IntegrationTest
  test "should send attached lyrics" do
    song = songs(:mp3_sample)
    song.lyrics.attach(io: StringIO.new("[00:01.00]attached"), filename: "sample.lrc", content_type: "text/plain")

    login
    get song_lyrics_url(song)

    assert_redirected_to url_for(song.lyrics)
  end

  test "should send external lyrics file when song has no attached lyrics" do
    with_external_lyrics_file("[00:01.00]external") do |song|
      login
      get song_lyrics_url(song)

      assert_response :success
      assert_equal "text/plain", @response.media_type
      assert_equal "[00:01.00]external", @response.body
    end
  end

  test "should send attached lyrics first when song also has external lyrics file" do
    with_external_lyrics_file("[00:01.00]external") do |song|
      song.lyrics.attach(io: StringIO.new("[00:01.00]attached"), filename: "sample.lrc", content_type: "text/plain")

      login
      get song_lyrics_url(song)

      assert_redirected_to full_url_for(song.lyrics)
    end
  end

  test "should get no content when song has no lyrics" do
    login
    get song_lyrics_url(songs(:mp3_sample))

    assert_response :no_content
  end
end
