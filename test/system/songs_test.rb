# frozen_string_literal: true

require 'application_system_test_case'

class SongsTest < ApplicationSystemTestCase
  setup do
    # create many record to test infinite scroll
    (Pagy::VARS[:items] * 2).times do |n|
      Song.create(
        name: "song_test_#{n}",
        file_path: Rails.root.join('test/fixtures/files/artist1_album2.mp3'),
        md5_hash: 'fake_md5',
        artist_id: artists(:artist1).id,
        album_id: albums(:album1).id
      )
    end

    login_as users(:visitor1)
  end

  test 'show songs' do
    visit songs_url

    assert_selector('#test-main-content .c-tab__item.is-active a', text: 'Songs')
    assert_selector('#turbo-songs-content > .o-grid', count: Pagy::VARS[:items])
  end

  test 'show next page songs when scroll to the bottom' do
    visit songs_url
    find('#test-main-content').scroll_to :bottom

    assert_selector('#turbo-songs-content > .o-grid', count: Pagy::VARS[:items] * 2)
  end
end
