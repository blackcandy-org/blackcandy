# frozen_string_literal: true

require "test_helper"

class Api::V1::CachedTranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    stream = Stream.new(songs(:flac_sample))
    FileUtils.touch(stream.transcode_cache_file_path)

    login
  end

  test "should get stream" do
    get new_api_v1_cached_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success
  end

  test "should set header for nginx send file" do
    get new_api_v1_cached_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_equal "/private_cache_media/2/ZmxhY19zYW1wbGVfbWQ1X2hhc2g=_128.mp3", @response.get_header("X-Accel-Redirect")
  end

  test "should set correct content type header" do
    get new_api_v1_cached_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_equal "audio/mpeg", @response.get_header("Content-Type")
  end
end
