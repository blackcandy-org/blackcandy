# frozen_string_literal: true

require "test_helper"

class CachedTranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    stream = Stream.new(songs(:flac_sample))
    FileUtils.touch(stream.transcode_cache_file_path)
  end

  test "should get stream" do
    assert_login_access(url: new_cached_transcoded_stream_url(song_id: songs(:flac_sample).id)) do
      assert_response :success
    end
  end

  test "should set header for nginx send file" do
    assert_login_access(url: new_cached_transcoded_stream_url(song_id: songs(:flac_sample).id)) do
      assert_equal "/private_cache_media/2/ZmFrZV9tZDU=_128.mp3", @response.get_header("X-Accel-Redirect")
    end
  end
end
