# frozen_string_literal: true

require "test_helper"

class SongTest < ActiveSupport::TestCase
  test "should get file format" do
    assert_equal "mp3", songs(:mp3_sample).format
    assert_equal "flac", songs(:flac_sample).format
    assert_equal "ogg", songs(:ogg_sample).format
    assert_equal "wav", songs(:wav_sample).format
    assert_equal "opus", songs(:opus_sample).format
    assert_equal "m4a", songs(:m4a_sample).format
  end

  test "should remove relative cache files when destroyed" do
    stream = Stream.new(songs(:flac_sample))
    FileUtils.touch(stream.transcode_cache_file_path)
    assert File.exist?(stream.transcode_cache_file_path)

    songs(:flac_sample).destroy
    assert_not File.exist?(stream.transcode_cache_file_path)
  end
end
