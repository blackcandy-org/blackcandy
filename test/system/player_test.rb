# frozen_string_literal: true

require 'application_system_test_case'

class PlayerSystemTest < ApplicationSystemTestCase
  setup do
    Setting.update(media_path: Rails.root.join('test/fixtures/files'))
    users(:visitor1).current_playlist.replace(Song.ids)
    login_as users(:visitor1)
  end

  test 'play song' do
    find('#test-player-play-button').click

    assert_selector('#test-player-play-button', visible: false)
    assert_selector('#test-player-pause-button', visible: true)
    assert_selector('.c-player__header', visible: true)
    assert_selector('.c-player__header__content', text: Song.first.name)
  end

  test 'pause song' do
    find('#test-player-play-button').click
    assert_selector('#test-player-play-button', visible: false)
    assert_selector('#test-player-pause-button', visible: true)

    find('#test-player-pause-button').click
    assert_selector('#test-player-play-button', visible: true)
    assert_selector('#test-player-pause-button', visible: false)
  end

  test 'play next song' do
    find('#test-player-play-button').click
    find('#test-player-next-button').click

    assert_selector('.c-player__header', visible: true)
    assert_selector('.c-player__header__content', text: Song.second.name)
  end

  test 'play previous song' do
    find('#test-player-play-button').click
    find('#test-player-previous-button').click

    assert_selector('.c-player__header', visible: true)
    assert_selector('.c-player__header__content', text: Song.last.name)
  end

  test 'favorite toggle' do
    find('#test-player-play-button').click
    assert_selector('#turbo-playlist .c-list .c-list__item:first-child', text: Song.first.name)

    find('#test-player-favorite-button').click
    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Favorites')
    assert_selector(
      "#favorite_playlist_#{users(:visitor1).favorite_playlist.id} .c-list__item:first-child",
      text: Song.first.name
    )

    find('#test-player-favorite-button').click
    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Favorites')
    assert_text('No items')
  end
end
