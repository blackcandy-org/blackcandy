# frozen_string_literal: true

require "test_helper"

class Api::V1::TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))

    cache_directory = "#{Stream::TRANSCODE_CACHE_DIRECTORY}/#{songs(:flac_sample).id}"
    if Dir.exist?(cache_directory)
      FileUtils.remove_dir(cache_directory)
    end

    login
  end

  test "should get new stream for transcode format" do
    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success
  end

  test "should get transcoded data" do
    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)

    create_tmp_file(format: "mp3") do |tmp_file_path|
      File.write(tmp_file_path, response.body)

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should write cache when don't find cache" do
    stream = Stream.new(songs(:flac_sample))
    assert_not File.exist? stream.transcode_cache_file_path

    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)

    assert_response :success
    assert File.exist? stream.transcode_cache_file_path
  end

  test "should send cached transcoded stream file when found cache" do
    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success

    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_equal binary_data(Stream.new(songs(:flac_sample)).transcode_cache_file_path), response.body
  end

  test "should send cached transcoded stream file when found cache and send file with nginx" do
    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success

    stub_env("NGINX_SENDFILE", "true") do
      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
      assert_equal "/private_cache_media/2/ZmxhY19zYW1wbGVfbWQ1X2hhc2g=_128.mp3", @response.get_header("X-Accel-Redirect")
      assert_equal "audio/mpeg", @response.get_header("Content-Type")
    end
  end

  test "should regenerate new cache when cache is invalid" do
    stream = Stream.new(songs(:flac_sample))

    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success

    original_cache_file_mtime = File.mtime(stream.transcode_cache_file_path)

    # Make the duration of the song different from the duration of the cache,
    # so that the cache will be treated as invalid
    songs(:flac_sample).update(duration: 12.0)

    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success

    assert_not_equal original_cache_file_mtime, File.mtime(stream.transcode_cache_file_path)
  end

  test "should set correct content type header" do
    get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_equal "audio/mpeg", @response.get_header("Content-Type")
  end
end
