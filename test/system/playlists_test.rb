# frozen_string_literal: true

require "application_system_test_case"

class PlaylistsSystemTest < ApplicationSystemTestCase
  setup do
    login_as users(:admin)
  end

  test "show playlist" do
    click_on "Playlists"

    users(:admin).playlists.each do |playlist|
      assert_selector(:test_id, "playlist_name", text: playlist.name)
    end
  end

  test "create playlist" do
    click_on "Playlists"
    fill_in "playlist_name", with: "test-playlist"
    click_on "Create"

    assert_equal "test-playlist", first(:test_id, "playlist_name").text
  end
end
