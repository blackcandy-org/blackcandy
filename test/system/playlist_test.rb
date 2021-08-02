# frozen_string_literal: true

require 'application_system_test_case'

class PlaylistTest < ApplicationSystemTestCase
  setup do
    Setting.update(media_path: Rails.root.join('test/fixtures/files'))
    login_as users(:admin)
    click_on 'Playlists'
    click_on 'playlist1'
  end

  test 'show playlist songs' do
    playlists(:playlist1).songs.each do |song|
      assert_selector('#turbo-playlist .c-list .c-list__item', text: song.name)
    end
  end

  test 'play all songs in playlist' do
    find('#turbo-playlist .c-action-bar .c-dropdown').click
    click_on 'Play all'

    # assert current playlist have all songs in playlist
    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Current')
    playlists(:playlist1).songs.each do |song|
      assert_selector('#turbo-playlist .c-list .c-list__item', text: song.name)
    end

    # assert play the first song in playlist
    assert_selector('.c-player__header__content', text: playlists(:playlist1).songs.first.name)
  end

  test 'clear playlist songs' do
    find('#turbo-playlist .c-action-bar .c-dropdown').click
    click_on 'Clear'

    assert_selector('#turbo-playlist .c-list .c-list__item', count: 0)
    assert_selector('#turbo-playlist .c-action-bar', text: '0 Tracks')
  end

  test 'delete playlist' do
    find('#turbo-playlist .c-action-bar .c-dropdown').click
    click_on 'Delete'

    assert_selector('#turbo-playlist .c-list .c-list__item', count: 0)
  end

  test 'rename playlist' do
    find('#turbo-playlist .c-action-bar .c-dropdown').click
    click_on 'Rename'

    fill_in 'test-playlist-name-input', with: 'renamed_playlist'
    # blur the input
    find('body').click

    assert_selector('#turbo-playlist .c-action-bar', text: 'renamed_playlist')
  end

  test 'delete song in playlist' do
    playlist_songs_count = playlists(:playlist1).songs.count

    find('#turbo-playlist .c-list .c-list__item:first-child .c-dropdown').click
    click_on 'Delete'

    assert_selector('#turbo-playlist .c-list .c-list__item', count: playlist_songs_count - 1)
  end

  test 'reorder song in playlist' do
    first_playlist_song_name = playlists(:playlist1).songs.first.name
    source_element = find('#turbo-playlist .c-list .c-list__item:first-child .js-playlist-sortable-item-handle')
    target_element = find('#turbo-playlist .c-list .c-list__item:last-child .js-playlist-sortable-item-handle')
    source_element.drag_to(target_element)

    assert_selector('#turbo-playlist .c-list .c-list__item:last-child', text: first_playlist_song_name)
  end

  test 'play song in playlist' do
    find('#turbo-playlist .c-list .c-list__item:first-child').click

    assert_selector('.c-player__header', visible: true)
    assert_selector('.c-player__header__content', text: playlists(:playlist1).songs.first.name)
  end

  test 'add song to another playlist' do
    Playlist.create(name: 'test-playlist', user_id: users(:admin).id)

    find('#turbo-playlist .c-list .c-list__item:first-child .c-dropdown').click
    click_on 'Add to playlist'

    assert_selector('#turbo-dialog .c-dialog', visible: true)

    find('#turbo-dialog-playlists > form:first-child').click

    assert_selector('#turbo-playlist .c-nav .c-tab__item.is-active', text: 'Playlists')
    assert_selector('#turbo-playlist .c-action-bar', text: 'test-playlist')
    assert_selector('#turbo-playlist .c-list .c-list__item:first-child', text: playlists(:playlist1).songs.first.name)
  end
end
