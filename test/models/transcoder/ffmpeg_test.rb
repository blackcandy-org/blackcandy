# frozen_string_literal: true

require "test_helper"

class Transcoder::FfmpegTest < ActiveSupport::TestCase
  test "probes duration from the file rather than the tags" do
    duration = Transcoder::Ffmpeg.duration(songs(:flac_sample).file_path)

    assert_in_delta 8.0, duration, 0.1
  end

  test "returns no duration for a file it cannot read" do
    assert_nil Transcoder::Ffmpeg.duration("/nonexistent/file.flac")
  end

  test "fills exactly the requested number of bytes" do
    [ 1, 2, 3, 17, 128, 417, 418, 900, 3365, 4096 ].each do |size|
      assert_equal size, Transcoder::Ffmpeg.padding(size, 128).bytesize, "padding of #{size} bytes"
    end
  end

  test "returns nothing for a non positive request" do
    assert_equal "", Transcoder::Ffmpeg.padding(0, 128)
    assert_equal "", Transcoder::Ffmpeg.padding(-5, 128)
  end

  # The remainder that cannot hold another whole frame is a tag style trailer,
  # never a part frame and never null bytes.
  test "ends on a trailer rather than a truncated frame" do
    padding = Transcoder::Ffmpeg.padding(3365, 128)

    assert_match(/TAG *\z/n, padding)
  end

  test "seeks with input seeking so a restart is cheap" do
    command = Transcoder::Ffmpeg.stream_command("/tmp/x.flac", 128, seek: 42.5)

    assert_equal "-ss", command[1]
    assert_equal "42.500000", command[2]
    assert_operator command.index("-ss"), :<, command.index("-i")
  end

  # Without -to a bounded range makes ffmpeg encode to the end of the track
  # until we kill it. -to lands within the usual few hundred bytes of encoder
  # overshoot, which the padding already accounts for.
  test "bounds the encoder when an end timestamp is given" do
    command = Transcoder::Ffmpeg.stream_command("/tmp/x.flac", 128, seek: 62.5, stop: 68.75)

    assert_equal "-to", command[3]
    assert_equal "68.750000", command[4]
    assert_operator command.index("-to"), :<, command.index("-i")
  end

  test "leaves the encoder unbounded when no end timestamp is given" do
    assert_not_includes Transcoder::Ffmpeg.stream_command("/tmp/x.flac", 128, seek: 1.0), "-to"
    assert_not_includes Transcoder::Ffmpeg.stream_command("/tmp/x.flac", 128), "-to"
  end

  test "writes a bare frame stream so the byte to time map stays exact" do
    command = Transcoder::Ffmpeg.stream_command("/tmp/x.flac", 128)

    assert_includes command.each_cons(2).to_a, [ "-write_xing", "0" ]
    assert_includes command.each_cons(2).to_a, [ "-id3v2_version", "0" ]
    assert_includes command.each_cons(2).to_a, [ "-write_id3v1", "0" ]
  end
end
