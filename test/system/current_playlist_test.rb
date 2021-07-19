# frozen_string_literal: true

require 'application_system_test_case'

class CurrentPlaylistTest < ApplicationSystemTestCase
  setup do
    Setting.update(media_path: Rails.root.join('test/fixtures/files'))
    users(:visitor1).current_playlist.replace(Song.ids)
    login_as users(:visitor1)
  end

  test 'show playlist songs' do
    assert_selector('#turbo-playlist .c-list .c-list__item', count: Song.count)

    Song.all.each do |song|
      assert_selector('#turbo-playlist .c-list .c-list__item', text: song.name)
    end
  end

  test 'clear playlist songs' do
    find('#turbo-playlist .c-action-bar .c-dropdown').click
    click_on 'Clear'

    assert_selector('#turbo-playlist .c-list .c-list__item', count: 0)
    assert_text('No items')
  end

  test 'play song in playlist' do
    find('#turbo-playlist .c-list .c-list__item:first-child').click

    assert_selector('.c-player__header', visible: true)
    assert_selector('.c-player__header__content', text: Song.first.name)
  end

  test 'delete song in playlist' do
    find('#turbo-playlist .c-list .c-list__item:first-child .c-dropdown').click
    click_on 'Delete'

    assert_selector('#turbo-playlist .c-list .c-list__item', count: Song.count - 1)
  end

  test 'reorder song in playlist' do
    source_element = find('#turbo-playlist .c-list .c-list__item:first-child .js-playlist-sortable-item-handle')
    target_element = find('#turbo-playlist .c-list .c-list__item:last-child .js-playlist-sortable-item-handle')
    source_element.drag_to(target_element)

    assert_selector('#turbo-playlist .c-list .c-list__item:last-child', text: Song.first.name)
  end

  test 'add to playlist' do
    Playlist.create(name: 'test-playlist', user_id: users(:visitor1).id)

    find('#turbo-playlist .c-list .c-list__item:first-child .c-dropdown').click
    click_on 'Add to playlist'

    assert_selector('#turbo-dialog .c-dialog', visible: true)

    find('#turbo-dialog-playlists > form:first-child').click

    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Playlists')
    assert_selector('#turbo-playlist .c-action-bar', text: 'test-playlist')
    assert_selector('#turbo-playlist .c-list .c-list__item:first-child', text: Song.first.name)
  end
end
