# frozen_string_literal: true

require "test_helper"

class Playlists::SelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get playlists_selections_url

    assert_response :success
  end
end
