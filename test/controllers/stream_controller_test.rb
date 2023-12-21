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
end
