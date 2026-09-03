# frozen_string_literal: true

require "test_helper"

class Transcoder::ByteRangeTest < ActiveSupport::TestCase
  SIZE = 132_096

  test "predicts size from the linear byte to time map" do
    assert_equal 128_000, Transcoder::ByteRange.predicted_size(8.0, 128)
    assert_equal 4_800_000, Transcoder::ByteRange.predicted_size(300.0, 128)
    assert_equal 12_000_000, Transcoder::ByteRange.predicted_size(300.0, 320)
  end

  test "declares size with a margin the encoder can overshoot into" do
    assert_equal 132_096, Transcoder::ByteRange.declared_size(8.0, 128)
    assert_equal 4_096, Transcoder::ByteRange.declared_size(0.0, 128)
  end

  test "converts a byte offset back to a timestamp" do
    assert_in_delta 0.0, Transcoder::ByteRange.seconds_at(0, 128), 0.0001
    assert_in_delta 30.0, Transcoder::ByteRange.seconds_at(480_000, 128), 0.0001
  end

  test "returns nil when no range was requested" do
    assert_nil Transcoder::ByteRange.parse(nil, SIZE)
    assert_nil Transcoder::ByteRange.parse("", SIZE)
  end

  test "parses an open ended range" do
    range = Transcoder::ByteRange.parse("bytes=1000-", SIZE)

    assert_equal 1000, range.first
    assert_equal SIZE - 1, range.last
    assert_equal SIZE - 1000, range.length
  end

  # A scrubbing audio element sends open ended ranges, so ignoring the end of a
  # bounded range survives casual browser testing. Safari and AVPlayer open
  # with a small bounded probe and are badly confused by a reply that runs to
  # the end of the file.
  test "parses a bounded range as exactly the requested window" do
    range = Transcoder::ByteRange.parse("bytes=1000000-1099999", SIZE + 2_000_000)

    assert_equal 1_000_000, range.first
    assert_equal 1_099_999, range.last
    assert_equal 100_000, range.length
  end

  test "parses the two byte opening probe" do
    range = Transcoder::ByteRange.parse("bytes=0-1", SIZE)

    assert_equal 0, range.first
    assert_equal 1, range.last
    assert_equal 2, range.length
  end

  test "parses a suffix range" do
    range = Transcoder::ByteRange.parse("bytes=-500", SIZE)

    assert_equal SIZE - 500, range.first
    assert_equal SIZE - 1, range.last
    assert_equal 500, range.length
  end

  test "clamps a range that runs past the end" do
    range = Transcoder::ByteRange.parse("bytes=100-999999999", SIZE)

    assert_equal 100, range.first
    assert_equal SIZE - 1, range.last
  end

  test "rejects a range that starts past the end" do
    assert_equal :unsatisfiable, Transcoder::ByteRange.parse("bytes=99999999-", SIZE)
  end

  test "rejects a malformed range" do
    assert_equal :unsatisfiable, Transcoder::ByteRange.parse("bytes=abc", SIZE)
    assert_equal :unsatisfiable, Transcoder::ByteRange.parse("items=0-1", SIZE)
    assert_equal :unsatisfiable, Transcoder::ByteRange.parse("bytes=500-100", SIZE)
  end

  test "formats a content range header" do
    range = Transcoder::ByteRange.new(0, 1)

    assert_equal "bytes 0-1/#{SIZE}", range.content_range(SIZE)
  end
end
