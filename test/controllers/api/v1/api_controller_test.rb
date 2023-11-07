# frozen_string_literal: true

require "test_helper"

class Api::V1::ApiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:visitor1)
    @song = songs(:mp3_sample)
  end

  test "should not authenticate when use session" do
    login(@user)
    get api_v1_song_url(@song), as: :json

    assert_response :unauthorized
  end

  test "should authenticate when have api token" do
    get api_v1_song_url(@song), as: :json, headers: api_token_header(@user)

    assert_response :success
  end

  test "should not authenticate when do not have api token" do
    get api_v1_song_url(@song), as: :json

    assert_response :unauthorized
  end
end
