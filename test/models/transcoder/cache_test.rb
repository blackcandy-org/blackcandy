# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class Transcoder::CacheTest < ActiveSupport::TestCase
  BITRATE = 128

  setup do
    # Tests run in parallel processes that would otherwise share one cache
    # directory and clear it out from under each other.
    @cache_path = Dir.mktmpdir("transcoder-test")
    Transcoder.configure { |config| config.cache_path = @cache_path }

    @song = songs(:flac_sample)
  end

  teardown do
    Transcoder::Cache.clear
    Transcoder.configure do |config|
      config.cache_size = nil
      config.cache_path = nil
    end
    FileUtils.remove_entry(@cache_path) if File.exist?(@cache_path)
  end

  # Keyed on md5_hash rather than song_id, so the entry survives a re-scan that
  # changes the row id and self-invalidates when the file content changes.
  test "keys on content rather than row id" do
    key = Transcoder::Cache.key(@song, BITRATE)

    assert_equal key, Transcoder::Cache.key(@song, BITRATE)
    assert_not_equal key, Transcoder::Cache.key(@song, 320)

    @song.md5_hash = "something else"
    assert_not_equal key, Transcoder::Cache.key(@song, BITRATE)
  end

  test "fans the key out over a subdirectory" do
    key = Transcoder::Cache.key(@song, BITRATE)

    assert_equal Transcoder::Cache.root.join(key[0, 2], "#{key}.mp3"), Transcoder::Cache.path(key)
  end

  test "gives each process its own part file so two workers cannot interleave" do
    key = Transcoder::Cache.key(@song, BITRATE)

    assert_includes Transcoder::Cache.part_path(key).to_s, Process.pid.to_s
    assert_not_equal Transcoder::Cache.path(key), Transcoder::Cache.part_path(key)
  end

  # N concurrent callers for the same cold key get one encode and N readers of
  # one part file, rather than N encoders interleaving bytes into one path.
  test "collapses concurrent callers onto a single encode" do
    encodes = 4.times.map do
      Thread.new { Transcoder::Cache.encode_for(song: @song, bitrate: BITRATE, duration: 8.0) }
    end.map(&:value)

    assert_equal 1, encodes.uniq(&:object_id).size
  end

  test "starts a fresh encode once the previous one has settled" do
    first = Transcoder::Cache.encode_for(song: @song, bitrate: BITRATE, duration: 8.0)
    wait_until { first.settled? }

    second = Transcoder::Cache.encode_for(song: @song, bitrate: BITRATE, duration: 8.0)

    assert_not_equal first.object_id, second.object_id
  end

  test "evicts least recently used entries over the size cap" do
    stale = write_entry("a", used_at: 2.hours.ago)
    fresh = write_entry("b", used_at: Time.now)

    Transcoder.configure { |config| config.cache_size = 0.1 }
    Transcoder::Cache.sweep

    assert_not File.exist?(stale)
    assert File.exist?(fresh)
  end

  test "keeps everything when the cache is under the cap" do
    stale = write_entry("a", used_at: 2.hours.ago)
    fresh = write_entry("b", used_at: Time.now)

    Transcoder.configure { |config| config.cache_size = 10 }
    Transcoder::Cache.sweep

    assert File.exist?(stale)
    assert File.exist?(fresh)
  end

  # A part file with no live encoder behind it is debris from a crash.
  test "removes part files left behind by a crash" do
    stale = write_part("old", mtime: (Transcoder::Cache::STALE_PART_AGE + 1.hour).ago)
    recent = write_part("new", mtime: Time.now)

    Transcoder::Cache.sweep

    assert_not File.exist?(stale)
    assert File.exist?(recent)
  end

  private

  def write_entry(seed, used_at:, size: 60_000)
    key = Digest::SHA256.hexdigest(seed)
    path = Transcoder::Cache.path(key)

    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, "\0" * size)
    File.utime(used_at.to_time, used_at.to_time, path)

    path
  end

  def write_part(seed, mtime:)
    key = Digest::SHA256.hexdigest(seed)
    path = Transcoder::Cache.root.join(key[0, 2], "#{key}.#{Process.pid}.part")

    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, "partial")
    File.utime(mtime.to_time, mtime.to_time, path)

    path
  end

  def wait_until(timeout: 10)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    sleep 0.02 until yield || Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
  end
end
