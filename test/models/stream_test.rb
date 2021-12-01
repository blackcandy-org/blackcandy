# frozen_string_literal: true

require "test_helper"

class StreamTest < ActiveSupport::TestCase
  test "should check song if need transcode" do
    assert Stream.new(songs(:flac_sample)).need_transcode?
    assert Stream.new(songs(:wav_sample)).need_transcode?
    assert Stream.new(songs(:oga_sample)).need_transcode?
    assert Stream.new(songs(:wma_sample)).need_transcode?
    assert_not Stream.new(songs(:mp3_sample)).need_transcode?
    assert_not Stream.new(songs(:m4a_sample)).need_transcode?
    assert_not Stream.new(songs(:ogg_sample)).need_transcode?
    assert_not Stream.new(songs(:opus_sample)).need_transcode?
  end

  test "should can transcode flac format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:flac_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should can transcode wav format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:wav_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should can transcode ogg format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:ogg_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should can transcode opus format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:opus_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should can transcode oga format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:oga_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test "should can transcode wma format" do
    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:wma_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end
end
