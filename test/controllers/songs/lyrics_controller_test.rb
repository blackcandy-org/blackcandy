# frozen_string_literal: true

require "test_helper"

class Songs::LyricsControllerTest < ActionDispatch::IntegrationTest
  test "should get lyrics" do
    song = songs(:mp3_sample)
    song.update!(lyrics: "[00:01.00]first line\n[00:02.00]second line")

    login
    get song_lyrics_url(song)

    assert_response :success
    assert_includes @response.body, "first line"
    assert_includes @response.body, "second line"
    assert_not_includes @response.body, "[00:01.00]"
  end

  test "should get lyrics from external lyrics file when song has no lyrics" do
    with_external_lyrics_file("[00:01.00]external line") do |song|
      login
      get song_lyrics_url(song)

      assert_response :success
      assert_includes @response.body, "external line"
    end
  end

  test "should get no lyrics message when song has no lyrics" do
    login
    get song_lyrics_url(songs(:mp3_sample))

    assert_response :success
    assert_includes @response.body, I18n.t("label.no_lyrics")
  end

  test "should get lyrics via api" do
    song = songs(:mp3_sample)
    song.update!(lyrics: "[00:01.00]first line")

    get song_lyrics_url(song), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_equal "[00:01.00]first line", @response.parsed_body["lyrics"]
  end

  test "should get null lyrics when song has no lyrics via api" do
    get song_lyrics_url(songs(:mp3_sample)), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_nil @response.parsed_body["lyrics"]
  end
end
