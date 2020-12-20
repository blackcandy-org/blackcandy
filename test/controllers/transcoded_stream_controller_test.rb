# frozen_string_literal: true

require 'test_helper'

class TranscodedStreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.update(media_path: Rails.root.join('test/fixtures/files'))
  end

  test 'should get new stream for transcode format' do
    assert_login_access(url: new_transcoded_stream_url(song_id: songs(:flac_sample).id)) do
      assert_response :success
    end
  end

  test 'should get transcoded data' do
    assert_login_access(url: new_transcoded_stream_url(song_id: songs(:flac_sample).id)) do
      create_tmp_file(format: 'mp3') do |tmp_file_path|
        File.open(tmp_file_path, 'w') do |file|
          file.write response.body
        end

        assert_equal 128, audio_bitrate(tmp_file_path)
      end
    end
  end
end
