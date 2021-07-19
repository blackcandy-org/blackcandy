# frozen_string_literal: true

require 'application_system_test_case'

class PlaylistsTest < ApplicationSystemTestCase
  setup do
    login_as users(:admin)
  end

  test 'show playlist' do
    click_on 'Playlists'

    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Playlists')
    users(:admin).playlists.each do |playlist|
      assert_selector('#turbo-playlist .c-list .c-list__item', text: playlist.name)
    end
  end

  test 'create playlist' do
    click_on 'Playlists'
    fill_in 'playlist_name', with: 'test-playlist'
    click_on 'Create'

    assert_selector('#turbo-playlist .c-list .c-list__item:first-child', text: 'test-playlist')
  end
end
