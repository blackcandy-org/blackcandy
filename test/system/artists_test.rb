# frozen_string_literal: true

require "application_system_test_case"

class ArtistsSystemTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::DEFAULT[:items] * 2).times do |n|
      Artist.create(name: "artist_test_#{n}")
    end

    login_as users(:visitor1)
  end

  test "show artists" do
    visit artists_url

    assert_selector(:test_id, "artist_card", count: Pagy::DEFAULT[:items])
  end

  test "show next page artists when scroll to the bottom" do
    visit artists_url
    find(:test_id, "main_content").scroll_to :bottom

    assert_selector(:test_id, "artist_card", count: Pagy::DEFAULT[:items] * 2)
  end
end
