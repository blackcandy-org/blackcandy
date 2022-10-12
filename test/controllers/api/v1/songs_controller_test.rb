# frozen_string_literal: true

require "test_helper"

class Api::V1::SongsControllerTest < ActionDispatch::IntegrationTest
  test "should show song" do
    get api_v1_song_url(songs(:mp3_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal songs(:mp3_sample).name, response["name"]
  end

  test "should get transcoded stream url for unsupported format" do
    get api_v1_song_url(songs(:wma_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_api_v1_transcoded_stream_url(song_id: songs(:wma_sample).id), response["url"]
  end

  test "should get transcoded stream url for lossless formats when allow transcode lossless format" do
    Setting.update(allow_transcode_lossless: true)

    get api_v1_song_url(songs(:flac_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), response["url"]
  end

  test "should not get transcoded stream path for lossless formats when don't allow transcode lossless format" do
    Setting.update(allow_transcode_lossless: false)

    get api_v1_song_url(songs(:flac_sample)), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal new_api_v1_stream_url(song_id: songs(:flac_sample).id), response["url"]
  end
end
