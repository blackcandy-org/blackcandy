# frozen_string_literal: true

require "test_helper"

class TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)

    cache_directory = "#{Stream::TRANSCODE_CACHE_DIRECTORY}/#{songs(:flac_sample).id}"
    if Dir.exist?(cache_directory)
      FileUtils.remove_dir(cache_directory)
    end

    login(@user)
  end

  test "should get new stream for transcode format" do
    get new_transcoded_stream_url(song_id: songs(:flac_sample).id)
    assert_response :success
  end
end
