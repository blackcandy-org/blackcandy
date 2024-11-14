# frozen_string_literal: true

require "test_helper"

class Api::V1::StreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
  end

  test "should get new stream" do
    get new_api_v1_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_response :success
  end

  test "should respond file data" do
    get new_api_v1_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
  end

  test "should respond file data when set nginx send file header" do
    with_env("NGINX_SENDFILE" => "true") do
      get new_api_v1_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
      assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
    end
  end

  test "should set correct content type header" do
    get new_api_v1_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_equal "audio/mpeg", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
    assert_equal "audio/flac", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:ogg_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:wav_sample).id), headers: api_token_header(@user)
    assert_equal "audio/wav", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:opus_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:m4a_sample).id), headers: api_token_header(@user)
    assert_equal "audio/aac", @response.get_header("Content-Type")

    get new_api_v1_stream_url(song_id: songs(:oga_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")
  end

  test "should set correct content type header when not set nginx send file header" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "") do
      get new_api_v1_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
      assert_equal "audio/mpeg", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal "audio/flac", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:ogg_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:wav_sample).id), headers: api_token_header(@user)
      assert_equal "audio/wav", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:opus_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:m4a_sample).id), headers: api_token_header(@user)
      assert_equal "audio/aac", @response.get_header("Content-Type")

      get new_api_v1_stream_url(song_id: songs(:oga_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")
    end
  end
end
