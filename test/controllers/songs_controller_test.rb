# frozen_string_literal: true

require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get songs_url

    assert_response :success
  end
end
