# frozen_string_literal: true

require "test_helper"

class SongTest < ActiveSupport::TestCase
  test "should get file format or transcode format for support file" do
    assert_equal "mp3", songs(:mp3_sample).format
    assert_equal "mp3", songs(:flac_sample).format
    assert_equal "ogg", songs(:ogg_sample).format
    assert_equal "mp3", songs(:wav_sample).format
    assert_equal "opus", songs(:opus_sample).format
    assert_equal "m4a", songs(:m4a_sample).format
  end
end
