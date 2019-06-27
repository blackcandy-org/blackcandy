# frozen_string_literal: true

require 'test_helper'

class StreamTest < ActiveSupport::TestCase
  test 'should check song if need transcode' do
    assert Stream.new(songs(:flac_sample)).need_transcode?
    assert Stream.new(songs(:wav_sample)).need_transcode?
    assert_not Stream.new(songs(:mp3_sample)).need_transcode?
    assert_not Stream.new(songs(:m4a_sample)).need_transcode?
    assert_not Stream.new(songs(:ogg_sample)).need_transcode?
  end

  test 'should transcode flac format' do
    create_tmp_file(format: 'mp3') do |tmp_file_path|
      stream = Stream.new(songs(:flac_sample))

      File.open(tmp_file_path, 'w') do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end

  test 'should transcode wav format' do
    create_tmp_file(format: 'mp3') do |tmp_file_path|
      stream = Stream.new(songs(:wav_sample))

      File.open(tmp_file_path, 'w') do |file|
        stream.each { |data| file.write data }
      end

      assert_equal 128, audio_bitrate(tmp_file_path)
    end
  end
end
