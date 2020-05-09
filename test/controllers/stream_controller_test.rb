# frozen_string_literal: true

require 'test_helper'

class StreamControllerTest < ActionDispatch::IntegrationTest
  test 'should get new stream' do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_response :success
    end
  end

  test 'should redirect to transcoded stream path for transcode format' do
    assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
      assert_redirected_to new_transcoded_stream_url(song_id: songs(:flac_sample).id)
    end
  end

  test 'should set header for nginx send file' do
    Setting.media_path = Rails.root.join('test', 'fixtures', 'files')

    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal Setting.media_path, @response.get_header('X-Media-Path')
      assert_equal '/private_media/artist1_album2.mp3', @response.get_header('X-Accel-Redirect')
    end
  end

  test 'should respond file data' do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal binary_data(file_fixture('artist1_album2.mp3')), response.body
    end
  end

  test 'should respond file data when not set nginx send file header' do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, '') do
      assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
        assert_equal binary_data(file_fixture('artist1_album2.mp3')), response.body
      end
    end
  end
end
