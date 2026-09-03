# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @song = songs(:flac_sample)

    # Tests run in parallel processes that would otherwise share one cache
    # directory and clear it out from under each other.
    @cache_path = Dir.mktmpdir("transcoder-test")
    Transcoder.configure { |config| config.cache_path = @cache_path }
  end

  teardown do
    Transcoder.configure { |config| config.cache_path = nil }
    FileUtils.remove_entry(@cache_path) if File.exist?(@cache_path)
  end

  # Production always sets x_sendfile_header, so this is the cached path every
  # real deployment takes. Range on this path is the proxy's job, not ours.
  test "should serve a published cache entry through the proxy" do
    body = publish_cache_entry
    login(@user)

    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "X-Sendfile") do
      get new_transcoded_stream_url(song_id: @song.id)

      assert_response :success
      assert_equal "audio/mpeg", response.headers["Content-Type"]
      assert_equal body, response.body
    end
  end

  test "should serve a published cache entry through the proxy via api" do
    body = publish_cache_entry

    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "X-Sendfile") do
      get new_transcoded_stream_url(song_id: @song.id), headers: api_token_header(@user)

      assert_response :success
      assert_equal body, response.body
    end
  end

  # A cold entry has to come off the encoder as it is produced, which needs the
  # socket. The integration test rack stack does not offer full hijack;
  # Transcoder::ResponseTest drives that path over a socket pair instead.
  test "should report not implemented when the server cannot hijack" do
    login(@user)

    get new_transcoded_stream_url(song_id: @song.id)

    assert_response :not_implemented
  end

  test "should report not implemented when the server cannot hijack via api" do
    get new_transcoded_stream_url(song_id: @song.id), headers: api_token_header(@user)

    assert_response :not_implemented
  end

  # The socket beats streaming a cached file through Puma, because it keeps the
  # download off the pool either way.
  test "should still hand the socket to the transcoder for a cached entry" do
    publish_cache_entry
    login(@user)

    served = nil
    Transcoder.stub(:serve, ->(io, **options) { served = options }) do
      get new_transcoded_stream_url(song_id: @song.id), env: { "rack.hijack" => -> { :socket } }
    end

    assert_not_nil served
  end

  test "should hand the socket to the transcoder when the server can hijack" do
    login(@user)

    hijack_called = false
    served = nil

    Transcoder.stub(:serve, ->(io, **options) { served = options.merge(io: io) }) do
      get new_transcoded_stream_url(song_id: @song.id),
        env: { "rack.hijack" => -> { hijack_called = true; :socket } },
        headers: { "Range" => "bytes=100-199" }
    end

    assert hijack_called
    assert_equal :socket, served[:io]
    assert_equal @song, served[:song]
    assert_equal Setting.transcode_bitrate, served[:bitrate]
    assert_equal "bytes=100-199", served[:range]
  end

  private

  def cache_key
    Transcoder::Cache.key(@song, Setting.transcode_bitrate)
  end

  def publish_cache_entry
    path = Transcoder::Cache.path(cache_key)
    body = (("0".."9").to_a.join * 500).b

    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, body)

    body
  end
end
