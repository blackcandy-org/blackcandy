# frozen_string_literal: true

require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    assert_login_access(url: songs_url) do
      assert_response :success
    end
  end

  test "should show song" do
    assert_login_access(url: song_url(songs(:mp3_sample)), xhr: true) do
      assert_response :success
    end
  end
end
