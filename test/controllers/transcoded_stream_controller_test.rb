# frozen_string_literal: true

require "test_helper"

class TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  class StreamMock < Stream
    def initialize(song)
      super(song)
      @tmp_cache_file = Tempfile.new([ "", ".#{TRANSCODE_FORMAT}" ])
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
    @user = users(:visitor1)
    @stream_mock = StreamMock.new(songs(:flac_sample))

    cache_directory = "#{Stream::TRANSCODE_CACHE_DIRECTORY}/#{songs(:flac_sample).id}"
    FileUtils.rm_rf(cache_directory)
  end

  teardown do
    @stream_mock.close_tmp_cache_file
  end

  test "should get new stream for transcode format" do
    login(@user)
    get new_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success
  end

  test "should get new stream for transcode format via api" do
    Stream.stub(:new, @stream_mock) do
      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success
    end
  end

  test "should get transcoded data via api" do
    Stream.stub(:new, @stream_mock) do
      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)

      create_tmp_file(format: "mp3") do |tmp_file_path|
        File.write(tmp_file_path, response.body)

        assert_equal 128, audio_bitrate(tmp_file_path)
      end
    end
  end

  test "should write cache when don't find cache via api" do
    Stream.stub(:new, @stream_mock) do
      stream = Stream.new(songs(:flac_sample))
      assert File.empty? stream.transcode_cache_file_path

      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)

      assert_response :success
      assert_not File.empty? stream.transcode_cache_file_path
    end
  end

  test "should send cached transcoded stream file when found cache via api" do
    Stream.stub(:new, @stream_mock) do
      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal binary_data(Stream.new(songs(:flac_sample)).transcode_cache_file_path), response.body
    end
  end

  test "should regenerate new cache when cache is invalid via api" do
    Stream.stub(:new, @stream_mock) do
      stream = Stream.new(songs(:flac_sample))

      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      original_cache_file_mtime = File.mtime(stream.transcode_cache_file_path)

      # Make the duration of the song different from the duration of the cache,
      # so that the cache will be treated as invalid
      songs(:flac_sample).update(duration: 12.0)

      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success

      assert_not_equal original_cache_file_mtime, File.mtime(stream.transcode_cache_file_path)
    end
  end

  test "should set correct content type header via api" do
    Stream.stub(:new, @stream_mock) do
      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal "audio/mpeg", @response.get_header("Content-Type")
    end
  end

  test "should not treat an empty cache file as valid" do
    Stream.stub(:new, @stream_mock) do
      stream = Stream.new(songs(:flac_sample))

      # An empty cache file must be considered invalid so it gets regenerated
      # instead of being sent as a 0-byte response.
      FileUtils.mkdir_p(File.dirname(stream.transcode_cache_file_path))
      File.write(stream.transcode_cache_file_path, "")

      get new_transcoded_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_response :success
      assert_not_empty response.body
      assert_not File.zero?(stream.transcode_cache_file_path)
    end
  end
end
