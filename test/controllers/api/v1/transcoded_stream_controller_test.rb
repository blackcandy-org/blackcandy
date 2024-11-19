# frozen_string_literal: true

require "test_helper"

class Api::V1::TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  class StreamMock < Stream
    def initialize(song)
      super(song)
      @tmp_cache_file = Tempfile.new(["", ".#{TRANSCODE_FORMAT}"])
    end

    def transcode_cache_file_path
      @tmp_cache_file.path
    end

    def close_tmp_cache_file
      @tmp_cache_file.close
      @tmp_cache_file.unlink
    end
  end

  setup do
    @stream_mock = StreamMock.new(songs(:flac_sample))
    @user = users(:visitor1)
  end

  teardown do
    @stream_mock.close_tmp_cache_file
  end

  test "should get new stream for transcode format" do
    Stream.stub(:new, @stream_mock) do
      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success
    end
  end

  test "should get transcoded data" do
    Stream.stub(:new, @stream_mock) do
      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)

      create_tmp_file(format: "mp3") do |tmp_file_path|
        File.write(tmp_file_path, response.body)

        assert_equal 128, audio_bitrate(tmp_file_path)
      end
    end
  end

  test "should write cache when don't find cache" do
    Stream.stub(:new, @stream_mock) do
      stream = Stream.new(songs(:flac_sample))
      assert File.empty? stream.transcode_cache_file_path

      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)

      assert_response :success
      assert_not File.empty? stream.transcode_cache_file_path
    end
  end

  test "should send cached transcoded stream file when found cache" do
    Stream.stub(:new, @stream_mock) do
      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal binary_data(Stream.new(songs(:flac_sample)).transcode_cache_file_path), response.body
    end
  end

  test "should regenerate new cache when cache is invalid" do
    Stream.stub(:new, @stream_mock) do
      stream = Stream.new(songs(:flac_sample))

      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      original_cache_file_mtime = File.mtime(stream.transcode_cache_file_path)

      # Make the duration of the song different from the duration of the cache,
      # so that the cache will be treated as invalid
      songs(:flac_sample).update(duration: 12.0)

      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      assert_not_equal original_cache_file_mtime, File.mtime(stream.transcode_cache_file_path)
    end
  end

  test "should set correct content type header" do
    Stream.stub(:new, @stream_mock) do
      get new_api_v1_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal "audio/mpeg", @response.get_header("Content-Type")
    end
  end
end
