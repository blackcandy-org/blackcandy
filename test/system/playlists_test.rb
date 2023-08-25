# frozen_string_literal: true

require "application_system_test_case"

class PlaylistsSystemTest < ApplicationSystemTestCase
  setup do
    login_as users(:admin)
    visit playlists_url
  end

  test "show playlist" do
    users(:admin).all_playlists.each do |playlist|
      assert_selector(:test_id, "playlist_name", text: playlist.name)
    end
  end

  test "create playlist" do
    playlist_name = "test-playlist"

    click_on "Add"
    fill_in "playlist_name", with: playlist_name
    click_on "Save"

    assert_text("Created successfully")
    assert_selector(:test_id, "playlist_name", text: playlist_name)
  end
end
