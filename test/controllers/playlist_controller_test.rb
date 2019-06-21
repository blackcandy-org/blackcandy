# frozen_string_literal: true

require 'test_helper'

class PlaylistControllerTest < ActionDispatch::IntegrationTest
  test 'should show user current playlist' do
    assert_login_access(url: playlist_url('current'), xhr: true) do
      assert_response :success
    end
  end

  test 'should show user favorite playlist' do
    assert_login_access(url: playlist_url('favorite'), xhr: true) do
      assert_response :success
    end
  end

  test 'should show user song collection playlist' do
    song_collection = song_collections(:collection1)
    user = song_collection.user

    assert_login_access(user: user, url: playlist_url(song_collection), xhr: true) do
      assert_response :success
    end
  end

  test 'should update playlist' do
    flush_redis

    assert_login_access(method: :patch, url: playlist_url('current'), params: { update_action: 'push', song_id: 1 }, xhr: true) do |user|
      assert_equal [1], user.current_playlist.song_ids
    end

    assert_login_access(method: :patch, url: playlist_url('current'), params: { update_action: 'delete', song_id: 1 }, xhr: true) do |user|
      assert_equal [], user.current_playlist.song_ids
    end
  end

  test 'should destroy playlist' do
    flush_redis

    user = users(:visitor1)
    user.current_playlist.push(1, 2)

    assert_login_access(user: user, method: :delete, url: playlist_url('current'), xhr: true) do
      assert_equal [], user.current_playlist.song_ids
    end
  end

  test 'should play song from playlist' do
    flush_redis

    song_collection = song_collections(:collection1)
    user = song_collection.user
    song_collection.playlist.push(1, 2)

    assert_login_access(user: user, method: :post, url: play_playlist_url(song_collection), xhr: true) do
      assert_equal [1, 2], user.current_playlist.song_ids
    end
  end
end
