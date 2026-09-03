# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class Transcoder::ResponseTest < ActiveSupport::TestCase
  BITRATE = 128

  setup do
    # Tests run in parallel processes that would otherwise share one cache
    # directory and clear it out from under each other.
    @cache_path = Dir.mktmpdir("transcoder-test")
    Transcoder.configure { |config| config.cache_path = @cache_path }

    @song = songs(:flac_sample)
    @duration = Transcoder::Ffmpeg.duration(@song.file_path)
    @declared_size = Transcoder::ByteRange.declared_size(@duration, BITRATE)
  end

  teardown do
    Transcoder::Cache.clear
    Transcoder.configure { |config| config.cache_path = nil }
    FileUtils.remove_entry(@cache_path) if File.exist?(@cache_path)
  end

  test "serves the whole track with an exact content length" do
    response = fetch

    assert_equal 200, response[:status]
    assert_equal "audio/mpeg", response[:headers]["content-type"]
    assert_equal "bytes", response[:headers]["accept-ranges"]
    assert_equal @declared_size.to_s, response[:headers]["content-length"]
  end

  # The declared length is a prediction plus a margin, so the encoder has to
  # land on it exactly rather than merely close to it.
  test "delivers exactly the number of bytes it declared" do
    response = fetch

    assert_equal @declared_size, response[:body].bytesize
  end

  test "delivers audio the decoder accepts at the requested bitrate" do
    response = fetch

    create_tmp_file(format: "mp3") do |path|
      File.binwrite(path, response[:body])

      assert_equal BITRATE, audio_bitrate(path)
      assert_in_delta @duration, Transcoder::Ffmpeg.duration(path), 0.5
    end
  end

  test "transcodes every source format the players ask us to convert" do
    %i[flac_sample wav_sample ogg_sample opus_sample oga_sample wma_sample].each do |fixture|
      song = songs(fixture)
      body = fetch(song: song)[:body]

      create_tmp_file(format: "mp3") do |path|
        File.binwrite(path, body)

        assert_equal BITRATE, audio_bitrate(path), "#{fixture} did not transcode at #{BITRATE}k"
      end
    end
  end

  test "honours the configured bitrate" do
    body = fetch(bitrate: 192)[:body]

    create_tmp_file(format: "mp3") do |path|
      File.binwrite(path, body)

      assert_equal 192, audio_bitrate(path)
    end
  end

  # Null padding makes decoders reject the file, and silence cut short
  # mid-frame makes them report an invalid backstep. Neither shows up as a
  # failed decode, only as a warning, so the warnings are what we assert on.
  test "delivers audio the decoder accepts without complaint" do
    response = fetch

    create_tmp_file(format: "mp3") do |path|
      File.binwrite(path, response[:body])

      assert_empty decoder_warnings(path)
    end
  end

  test "answers a bounded range with exactly the requested window" do
    whole = fetch[:body]
    response = fetch(range: "bytes=1000-1099")

    assert_equal 206, response[:status]
    assert_equal "bytes 1000-1099/#{@declared_size}", response[:headers]["content-range"]
    assert_equal "100", response[:headers]["content-length"]
    assert_equal 100, response[:body].bytesize
    assert_equal whole.byteslice(1000, 100), response[:body]
  end

  test "answers the two byte opening probe" do
    whole = fetch[:body]
    response = fetch(range: "bytes=0-1")

    assert_equal 206, response[:status]
    assert_equal "bytes 0-1/#{@declared_size}", response[:headers]["content-range"]
    assert_equal 2, response[:body].bytesize
    assert_equal whole.byteslice(0, 2), response[:body]
  end

  test "answers an open ended range from a published entry" do
    whole = fetch_published[:body]
    offset = 40_000
    response = fetch(range: "bytes=#{offset}-")

    assert_equal 206, response[:status]
    assert_equal (@declared_size - offset), response[:body].bytesize
    assert_equal whole.byteslice(offset, @declared_size - offset), response[:body]
  end

  # Against a cold cache the same request may be answered by a second encoder
  # started at the offset, which is not byte identical to the first encode.
  # The declared length still has to hold whichever path is taken.
  test "answers an open ended range against a cold cache with the declared length" do
    offset = 40_000
    response = fetch(range: "bytes=#{offset}-")

    assert_equal 206, response[:status]
    assert_equal "bytes #{offset}-#{@declared_size - 1}/#{@declared_size}", response[:headers]["content-range"]
    assert_equal (@declared_size - offset), response[:body].bytesize
  end

  # The rule in §3 is an ETA comparison: wait for the head only when it will
  # arrive sooner than a fresh encoder could seek there.
  test "waits for the write head when it is nearer than a restart" do
    encode = encode_double(head: 30_000, rate: 2_000_000.0)

    assert_not response_for.send(:restart?, encode, Transcoder::ByteRange.new(40_000, @declared_size - 1))
  end

  test "restarts the encoder when the write head is too far behind" do
    encode = encode_double(head: 1_000, rate: 200_000.0)

    assert response_for.send(:restart?, encode, Transcoder::ByteRange.new(4_000_000, 4_800_000))
  end

  test "never restarts for a request that starts at the beginning" do
    encode = encode_double(head: 0, rate: 0.0)

    assert_not response_for.send(:restart?, encode, Transcoder::ByteRange.new(0, @declared_size - 1))
  end

  test "refuses a range past the end of the resource" do
    response = fetch(range: "bytes=99999999-")

    assert_equal 416, response[:status]
    assert_equal "bytes */#{@declared_size}", response[:headers]["content-range"]
    assert_empty response[:body]
  end

  test "publishes the cache entry atomically and serves the next request from it" do
    first = fetch
    key = Transcoder::Cache.key(@song, BITRATE)
    wait_for_publish(key)

    assert Transcoder::Cache.complete?(key)
    assert_empty Dir.glob(Transcoder::Cache.root.join("*", "*.part"))
    assert_equal @declared_size, File.size(Transcoder::Cache.path(key))

    assert_equal first[:body], fetch[:body]
  end

  test "streams without a length when the duration cannot be probed" do
    Transcoder::Ffmpeg.stub(:duration, nil) do
      response = fetch

      assert_equal 200, response[:status]
      assert_equal "chunked", response[:headers]["transfer-encoding"]
      assert_nil response[:headers]["content-length"]
    end
  end

  private

  def response_for(range: nil)
    Transcoder::Response.new(song: @song, bitrate: BITRATE, range: range)
  end

  def encode_double(head:, rate:)
    Struct.new(:head, :rate).new(head, rate)
  end

  # Streams the whole track and waits for the entry to be published, so a
  # following ranged request is served from cache rather than a restart.
  def fetch_published
    response = fetch
    wait_for_publish(Transcoder::Cache.key(@song, BITRATE))
    response
  end

  def fetch(range: nil, song: @song, bitrate: BITRATE)
    server, client = UNIXSocket.pair

    writer = Thread.new do
      Transcoder::Response.new(song: song, bitrate: bitrate, range: range).write_to(server)
    ensure
      server.close
    end

    raw = client.read
    writer.join
    client.close

    parse(raw)
  end

  def parse(raw)
    head, body = raw.split("\r\n\r\n", 2)
    lines = head.split("\r\n")
    status = lines.shift[%r{\AHTTP/1\.1 (\d+)}, 1].to_i

    headers = lines.to_h do |line|
      name, value = line.split(": ", 2)
      [ name.downcase, value ]
    end

    { status: status, headers: headers, body: body.to_s.b }
  end

  def decoder_warnings(path)
    output, _status = Open3.capture2e("ffmpeg", "-v", "warning", "-i", path.to_s, "-f", "null", "-")
    output.lines.map(&:strip).reject { |line| line.empty? || line.include?("Estimating duration") }
  end

  def wait_for_publish(key, timeout: 10)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

    until Transcoder::Cache.complete?(key) || Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
      sleep 0.02
    end
  end
end
