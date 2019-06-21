# frozen_string_literal: true

require 'test_helper'

class StreamControllerTest < ActionDispatch::IntegrationTest
  test 'should get new stream' do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_response :success
    end
  end

  test 'should get new stream for transcode format' do
    assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
      assert_response :success
    end
  end

  test 'should set header for nginx send file' do
    Setting.media_path = Rails.root.join('test', 'fixtures', 'files')

    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal Setting.media_path, @response.get_header('X-Media-Path')
      assert_equal '/private_media/artist1_album2.mp3', @response.get_header('X-Accel-Redirect')
    end
  end
end
