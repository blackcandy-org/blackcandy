# frozen_string_literal: true

require 'application_system_test_case'

class ArtistTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::VARS[:items] * 2).times do |n|
      Artist.create(name: "artist_test_#{n}")
    end

    login_as users(:visitor1)
  end

  test 'show artist' do
    visit artists_url

    assert_selector('#turbo-artists-content .c-card', count: Pagy::VARS[:items])
  end

  test 'show next page artists when scroll to the bottom' do
    visit artists_url
    find('#test-main-content').scroll_to :bottom

    assert_selector('#turbo-artists-content .c-card', count: Pagy::VARS[:items] * 2)
  end
end
