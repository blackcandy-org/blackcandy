# frozen_string_literal: true

require "test_helper"

class Search::PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get search_playlists_url(query: "test")

    assert_response :success
  end
end
