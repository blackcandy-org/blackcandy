# frozen_string_literal: true

require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    assert_login_access(url: songs_url) do
      assert_response :success
    end
  end
end
