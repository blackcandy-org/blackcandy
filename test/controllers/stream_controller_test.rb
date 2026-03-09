# frozen_string_literal: true

require "test_helper"

class StreamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    login(@user)
  end

  test "should get new stream" do
    get new_stream_url(song_id: songs(:mp3_sample).id)
    assert_response :success
  end

  test "should respond file data" do
    get new_stream_url(song_id: songs(:mp3_sample).id)
    assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
  end

  test "should respond file data when thruster sendfile is enabled" do
    Rails.configuration.action_dispatch.stub(:x_sendfile_header, "X-Sendfile") do
      get new_stream_url(song_id: songs(:mp3_sample).id)
      assert_equal binary_data(file_fixture("artist1_album2.mp3")), response.body
    end
  end
end
