# frozen_string_literal: true

require "application_system_test_case"

class ArtistSystemTest < ApplicationSystemTestCase
  setup do
    @artist = artists(:artist1)
  end

  test "show artist" do
    login_as users(:visitor1)
    visit artist_url(@artist)

    assert_text(@artist.name)

    @artist.albums.each do |album|
      assert_text(album.name)
    end
  end

  test "edit artist" do
    login_as users(:admin)
    visit artist_url(@artist)

    artist_original_image_url = find(:test_id, "artist_image")[:src]

    click_on "Edit"
    assert_selector(:test_id, "artist_edit_form", visible: true)

    attach_file("artist_cover_image", fixtures_file_path("cover_image.jpg"))
    click_on "Save"

    assert_text("Updated successfully")
    assert_not_equal artist_original_image_url, find(:test_id, "artist_image")[:src]
  end
end
