# frozen_string_literal: true

require "application_system_test_case"

class AlbumsSystemTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::DEFAULT[:items] * 2).times do |n|
      Album.create(name: "album_test_#{n}", artist_id: artists(:artist1).id)
    end

    login_as users(:visitor1)
  end

  test "show albums" do
    visit albums_url

    assert_selector(:test_id, "album_card", count: Pagy::DEFAULT[:items])
  end

  test "show next page albums when scroll to the bottom" do
    visit albums_url
    scroll_to :bottom

    assert_selector(:test_id, "album_card", count: Pagy::DEFAULT[:items] * 2)
  end
end
