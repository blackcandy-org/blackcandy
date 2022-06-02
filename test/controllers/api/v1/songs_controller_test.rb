# frozen_string_literal: true

require "test_helper"

class Api::V1::SongsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @song = songs(:mp3_sample)
  end

  test "should show song" do
    get api_v1_song_url(@song), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal @song.name, response["name"]
  end
end
