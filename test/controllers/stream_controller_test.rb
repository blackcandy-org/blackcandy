# frozen_string_literal: true

require "test_helper"

class StreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
  end

  test "should get new stream" do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_response :success
    end
  end

  test "should redirect to transcoded stream path for unsupported format" do
    assert_login_access(url: new_stream_url(song_id: songs(:wma_sample).id)) do
      assert_redirected_to new_transcoded_stream_url(song_id: songs(:wma_sample).id)
    end
  end

  test "should redirect to transcoded stream path for lossless formats when allow transcode lossless format" do
    Setting.update(allow_transcode_lossless: true)

    assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
      assert_redirected_to new_transcoded_stream_url(song_id: songs(:flac_sample).id)
    end
  end

  test "should not redirect to transcoded stream path for lossless formats when don't allow transcode lossless format" do
    Setting.update(allow_transcode_lossless: false)

    assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
      assert_response :success
    end
  end

  test "should set header for nginx send file" do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal Setting.media_path, @response.get_header("X-Media-Path")
      assert_equal "/private_media/artist1_album2.mp3", @response.get_header("X-Accel-Redirect")
    end
  end

  test "should respond file data" do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
    end
  end

  test "should respond file data when not set nginx send file header" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "") do
      assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
        assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
      end
    end
  end

  test "should set correct content type header" do
    assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
      assert_equal "audio/mpeg", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
      assert_equal "audio/flac", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:ogg_sample).id)) do
      assert_equal "audio/ogg", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:wav_sample).id)) do
      assert_equal "audio/wav", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:opus_sample).id)) do
      assert_equal "audio/ogg", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:m4a_sample).id)) do
      assert_equal "audio/aac", @response.get_header("Content-Type")
    end

    assert_login_access(url: new_stream_url(song_id: songs(:oga_sample).id)) do
      assert_equal "audio/ogg", @response.get_header("Content-Type")
    end
  end

  test "should set correct content type header when not set nginx send file header" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "") do
      assert_login_access(url: new_stream_url(song_id: songs(:mp3_sample).id)) do
        assert_equal "audio/mpeg", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:flac_sample).id)) do
        assert_equal "audio/flac", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:ogg_sample).id)) do
        assert_equal "audio/ogg", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:wav_sample).id)) do
        assert_equal "audio/wav", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:opus_sample).id)) do
        assert_equal "audio/ogg", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:m4a_sample).id)) do
        assert_equal "audio/aac", @response.get_header("Content-Type")
      end

      assert_login_access(url: new_stream_url(song_id: songs(:oga_sample).id)) do
        assert_equal "audio/ogg", @response.get_header("Content-Type")
      end
    end
  end
end
