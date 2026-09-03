# frozen_string_literal: true

require "test_helper"

class StreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
  end

  test "should get new stream" do
    login(@user)
    get new_stream_url(song_id: songs(:mp3_sample).id)
    assert_response :success
  end

  test "should respond file data" do
    login(@user)
    get new_stream_url(song_id: songs(:mp3_sample).id)
    assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
  end

  test "should respond file data when thruster sendfile is enabled" do
    login(@user)
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "X-Sendfile") do
      get new_stream_url(song_id: songs(:mp3_sample).id)
      assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
    end
  end

  # Rack::Files tags its refusals with x-cascade, which tells Rails to resume
  # routing and turns a 416 into a routing 404 if it reaches the response.
  test "should refuse a range past the end of the file" do
    login(@user)

    get new_stream_url(song_id: songs(:mp3_sample).id), headers: { "Range" => "bytes=99999999-" }

    assert_response :range_not_satisfiable
  end

  test "should answer a bounded range" do
    login(@user)

    get new_stream_url(song_id: songs(:mp3_sample).id), headers: { "Range" => "bytes=10-19" }

    assert_response :partial_content
    assert_equal 10, response.body.bytesize
    assert_equal "bytes", response.headers["Accept-Ranges"]
  end

  test "should get new stream via api" do
    get new_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_response :success
  end

  test "should respond file data via api" do
    get new_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
  end

  test "should respond file data when set send file header via api" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "X-Sendfile") do
      get new_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
      assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
    end
  end

  test "should set correct content type header via api" do
    get new_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
    assert_equal "audio/mpeg", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
    assert_equal "audio/flac", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:ogg_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:wav_sample).id), headers: api_token_header(@user)
    assert_equal "audio/wav", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:opus_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:m4a_sample).id), headers: api_token_header(@user)
    assert_equal "audio/aac", @response.get_header("Content-Type")

    get new_stream_url(song_id: songs(:oga_sample).id), headers: api_token_header(@user)
    assert_equal "audio/ogg", @response.get_header("Content-Type")
  end

  test "should set correct content type header when not set send file header via api" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "") do
      get new_stream_url(song_id: songs(:mp3_sample).id), headers: api_token_header(@user)
      assert_equal "audio/mpeg", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:flac_sample).id), headers: api_token_header(@user)
      assert_equal "audio/flac", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:ogg_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:wav_sample).id), headers: api_token_header(@user)
      assert_equal "audio/wav", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:opus_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:m4a_sample).id), headers: api_token_header(@user)
      assert_equal "audio/aac", @response.get_header("Content-Type")

      get new_stream_url(song_id: songs(:oga_sample).id), headers: api_token_header(@user)
      assert_equal "audio/ogg", @response.get_header("Content-Type")
    end
  end
end
