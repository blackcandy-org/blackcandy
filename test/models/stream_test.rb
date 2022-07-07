# frozen_string_literal: true

require "test_helper"

class StreamTest < ActiveSupport::TestCase
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

  test "should can transcode with different bitrate" do
    Setting.update(transcode_bitrate: 192)

    create_tmp_file(format: "mp3") do |tmp_file_path|
      stream = Stream.new(songs(:flac_sample))

      File.open(tmp_file_path, "w") do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 192, audio_bitrate(tmp_file_path)
    end
  end

  test "should get transcode cache file path" do
    stream = Stream.new(songs(:flac_sample))
    assert_equal "#{Stream::TRANSCODE_CACHE_DIRECTORY}/2/ZmxhY19zYW1wbGVfbWQ1X2hhc2g=_128.mp3", stream.transcode_cache_file_path
  end

  test "should get file duration" do
    stream = Stream.new(songs(:flac_sample))
    assert_equal 8.0, stream.duration
  end

  test "should get file format" do
    stream = Stream.new(songs(:flac_sample))
    assert_equal "flac", stream.format
  end
end
