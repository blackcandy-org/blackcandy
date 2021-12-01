# frozen_string_literal: true

require "application_system_test_case"

class ArtistSystemTest < ApplicationSystemTestCase
  setup do
    @artist = artists(:artist1)
  end

  test "show album" do
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

    artist_original_image_url = find(".test-artist-image")[:src]

    click_on "Edit"
    assert_selector("#turbo-dialog .c-dialog", visible: true)

    attach_file("artist_image", fixtures_file_path("cover_image.jpg"))
    click_on "Save"

    assert_text("Updated successfully")
    assert_not_equal artist_original_image_url, find(".test-artist-image")[:src]
  end
end
