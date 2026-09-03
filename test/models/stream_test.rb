# frozen_string_literal: true

require "test_helper"

class StreamTest < ActiveSupport::TestCase
  test "should get file format" do
    assert_equal "flac", Stream.new(songs(:flac_sample)).format
    assert_equal "mp3", Stream.new(songs(:mp3_sample)).format
  end

  test "should get file path" do
    assert_equal songs(:flac_sample).file_path, Stream.new(songs(:flac_sample)).file_path
  end
end
