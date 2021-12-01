# frozen_string_literal: true

require "test_helper"

class Search::AlbumsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    assert_login_access(url: search_albums_url(query: "test")) do
      assert_response :success
    end
  end
end
