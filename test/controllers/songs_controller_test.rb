# frozen_string_literal: true

require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get songs_url

    assert_response :success
  end

  test "should get index via api" do
    get songs_url, as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success

    song = songs(:mp3_sample)
    song_response = response.find { |item| item["id"] == song.id }

    assert_equal song.name, song_response["name"]
    assert_equal song.duration, song_response["duration"]
    assert_equal song.album_id, song_response["album_id"]
    assert_equal song.artist_id, song_response["artist_id"]
    assert_equal song.album.name, song_response["album_name"]
    assert_equal song.artist.name, song_response["artist_name"]
    assert song_response["url"].present?
    assert_equal song_lyrics_url(song), song_response["lyrics_url"]
    assert song_response["album_image_urls"]["small"].present?
    assert song_response["album_image_urls"]["medium"].present?
    assert song_response["album_image_urls"]["large"].present?
  end

  test "should show song via api" do
    get song_url(songs(:mp3_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal songs(:mp3_sample).name, response["name"]
  end

  test "should paginate index via api with limit param and link header" do
    Song.destroy_all
    5.times { |i| Song.create!(name: "song_#{i}", file_path: "/tmp/song_#{i}.mp3", file_path_hash: "hash_#{i}", md5_hash: "md5_#{i}", artist: artists(:artist1), album: albums(:album1)) }

    get songs_url(limit: 2, page: 2), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])

    assert_equal songs_url(limit: 2, page: 1), links["first"]
    assert_equal songs_url(limit: 2, page: 1), links["prev"]
    assert_equal songs_url(limit: 2, page: 3), links["next"]
    assert_equal songs_url(limit: 2, page: 3), links["last"]
  end

  test "should edit song" do
    login users(:admin)
    get edit_song_url(songs(:mp3_sample))

    assert_response :success
  end

  test "should update lyrics for song" do
    song = songs(:mp3_sample)
    login users(:admin)

    assert_changes -> { song.reload.lyrics.attached? } do
      patch song_url(song), params: { song: { lyrics: fixture_file_upload("sample.lrc", "text/plain") } }
    end

    assert_includes song.lyrics.download, "First line of lyrics"
  end

  test "should has error flash when failed to update song" do
    login users(:admin)
    patch song_url(songs(:mp3_sample)), params: { song: { lyrics: fixture_file_upload("cover_image.jpg", "image/jpeg") } }

    assert flash[:alert].present?
  end

  test "should only admin can edit song" do
    login

    get edit_song_url(songs(:mp3_sample))
    assert_response :forbidden

    patch song_url(songs(:mp3_sample)), params: { song: { lyrics: fixture_file_upload("sample.lrc", "text/plain") } }
    assert_response :forbidden
  end

  test "should not edit song when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get edit_song_url(songs(:mp3_sample))
      assert_response :forbidden

      patch song_url(songs(:mp3_sample)), params: { song: { lyrics: fixture_file_upload("sample.lrc", "text/plain") } }
      assert_response :forbidden
    end
  end

  test "should update lyrics for song via api" do
    song = songs(:mp3_sample)

    assert_changes -> { song.reload.lyrics.attached? } do
      patch song_url(song),
        params: { song: { lyrics: fixture_file_upload("sample.lrc", "text/plain") } },
        headers: api_token_header(users(:admin)).merge("Accept" => "application/json")
    end

    assert_response :success
    assert_equal song.id, @response.parsed_body["id"]
  end

  test "should return error response when failed to update song via api" do
    patch song_url(songs(:mp3_sample)),
      params: { song: { lyrics: fixture_file_upload("cover_image.jpg", "image/jpeg") } },
      headers: api_token_header(users(:admin)).merge("Accept" => "application/json")

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should get transcoded stream url for unsupported format via api" do
    get song_url(songs(:wma_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_transcoded_stream_url(song_id: songs(:wma_sample).id), response["url"]
  end

  test "should get transcoded stream url for lossless formats when allow transcode lossless format via api" do
    Setting.update(allow_transcode_lossless: true)

    get song_url(songs(:flac_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_transcoded_stream_url(song_id: songs(:flac_sample).id), response["url"]
  end

  test "should not get transcoded stream path for lossless formats when don't allow transcode lossless format via api" do
    Setting.update(allow_transcode_lossless: false)

    get song_url(songs(:flac_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_stream_url(song_id: songs(:flac_sample).id), response["url"]
  end
end
