# frozen_string_literal: true

require "test_helper"

class Dialog::PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get dialog_playlists_url

    assert_response :success
  end
end
