# frozen_string_literal: true

require 'test_helper'

class PlaylistableTest < ActiveSupport::TestCase
  setup do
    flush_redis
  end

  test 'should have playlist method when declared has_playlist method on class' do
    assert_respond_to song_collections(:song_collection1), :playlist
  end

  test 'should have named playlist method when declared has_playlists method on class' do
    assert_respond_to users(:visitor), :current_playlist
    assert_respond_to users(:visitor), :favorite_playlist
  end

  test 'should return instance of Playlist when call playlist method' do
    assert song_collections(:song_collection1).playlist.instance_of? Playlist
    assert users(:visitor).current_playlist.instance_of? Playlist
    assert users(:visitor).favorite_playlist.instance_of? Playlist
  end

  test 'should have data connection between playlist method and redis list' do
    playlist_redis_key = song_collections(:song_collection1).redis_field_key(:song_ids)

    song_collections(:song_collection1).playlist.push(1)
    assert_equal ['1'], Redis::Objects.redis.lrange(playlist_redis_key, 0, -1)
  end

  test 'should have data connection between named playlist method and redis list' do
    user = users(:visitor)
    current_playlist_redis_key = user.redis_field_key(:current_song_ids)
    favorite_playlist_redis_key = user.redis_field_key(:favorite_song_ids)

    user.current_playlist.push(1)
    user.favorite_playlist.push(1)

    assert_equal ['1'], Redis::Objects.redis.lrange(current_playlist_redis_key, 0, -1)
    assert_equal ['1'], Redis::Objects.redis.lrange(favorite_playlist_redis_key, 0, -1)
  end

  test 'should clean redis data after record removed' do
    song_collection = song_collections(:song_collection1)
    user = users(:visitor)

    playlist_redis_key = song_collection.redis_field_key(:song_ids)
    current_playlist_redis_key = user.redis_field_key(:current_song_ids)
    favorite_playlist_redis_key = user.redis_field_key(:favorite_song_ids)

    song_collection.playlist.push(1)
    user.current_playlist.push(1)
    user.favorite_playlist.push(1)

    assert Redis::Objects.redis.exists playlist_redis_key
    assert Redis::Objects.redis.exists current_playlist_redis_key
    assert Redis::Objects.redis.exists favorite_playlist_redis_key

    song_collection.destroy
    user.destroy

    assert_not Redis::Objects.redis.exists playlist_redis_key
    assert_not Redis::Objects.redis.exists current_playlist_redis_key
    assert_not Redis::Objects.redis.exists favorite_playlist_redis_key
  end
end
