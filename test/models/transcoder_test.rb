# frozen_string_literal: true

require "test_helper"

class TranscoderTest < ActiveSupport::TestCase
  teardown do
    Transcoder.configure { |config| config.max_concurrency = nil }
  end

  # Full hijack is a server capability. Rack::Test and the integration tests do
  # not provide it, which is what keeps them on the legacy path.
  test "is unavailable when the server does not offer full hijack" do
    assert_not Transcoder.available?(request_without_hijack)
  end

  test "is available when the server offers full hijack" do
    assert Transcoder.available?(request_with_hijack)
  end

  # Puma forks workers, and Solid Queue's plugin forks from the Puma process at
  # after_booted. After fork only the calling thread survives, so the
  # transcoder must not have started any thread before the first request.
  test "creates no threads before the first transcode" do
    before = Thread.list.size

    Transcoder.config.max_concurrency
    Transcoder.encode_semaphore
    Transcoder.restart_semaphore
    Transcoder::Cache.key(songs(:flac_sample), 128)

    assert_equal before, Thread.list.size
  end

  test "bounds concurrent encoders by configuration" do
    Transcoder.configure { |config| config.max_concurrency = 3 }

    assert_equal 3, Transcoder.encode_semaphore.available_permits
    assert_equal 3, Transcoder.restart_semaphore.available_permits
  end

  # A restart writes straight to the listener, so its ffmpeg lives as long as
  # they keep the stream open. Sharing a pool with encodes would let a handful
  # of stalled listeners block every first play on the server.
  test "a stalled restart cannot starve a new encode" do
    Transcoder.configure { |config| config.max_concurrency = 1 }

    Transcoder.restart_semaphore.acquire

    begin
      assert_equal 0, Transcoder.restart_semaphore.available_permits
      assert Transcoder.encode_semaphore.try_acquire(1, 1), "an encode should still get a permit"

      Transcoder.encode_semaphore.release
    ensure
      Transcoder.restart_semaphore.release
    end
  end

  private

  def request_without_hijack
    ActionDispatch::TestRequest.create
  end

  def request_with_hijack
    ActionDispatch::TestRequest.create.tap do |request|
      request.env["rack.hijack"] = -> { StringIO.new }
    end
  end
end
