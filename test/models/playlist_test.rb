# frozen_string_literal: true

require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  setup do
    flush_redis

    @redis_list = Redis::List.new('playlist')
    @playlist = Playlist.new(@redis_list)
  end

  test 'should raise error when song_ids are not Redis::List instance when init playlist' do
    assert_raises do
      Playlist.new([1, 2, 3])
    end
  end

  test 'should remove duplicate value when get song_ids' do
    @redis_list.push(1, 1, 2, 2, 3)

    assert_equal [1, 2, 3], @playlist.song_ids
  end

  test 'should get arbitrary ordered songs from database' do
    song_ids = Song.where(name: ['mp3_sample', 'm4a_sample', 'flac_sample']).ids.shuffle
    @redis_list.push(*song_ids)

    assert_equal song_ids, @playlist.songs.map(&:id)
  end

  test 'should support push multiple values or an array' do
    @playlist.push(1, 2)
    assert_equal ['1', '2'], @redis_list.values

    @playlist.push([3, 4])
    assert_equal ['1', '2', '3', '4'], @redis_list.values
  end

  test 'should support delete from multiple values or an array' do
    @playlist.push(1, 2, 3, 4)

    @playlist.delete(1, 2)
    assert_equal ['3', '4'], @redis_list.values

    @playlist.delete([3, 4])
    assert_equal [], @redis_list.values
  end

  test 'should support toggle value from list' do
    @playlist.push(1, 2)

    @playlist.toggle(3)
    assert_equal ['1', '2', '3'], @redis_list.values

    @playlist.toggle(2)
    assert_equal ['1', '3'], @redis_list.values
  end

  test 'should support clean up values' do
    @playlist.push(1, 2)
    @playlist.clear

    assert_equal [], @redis_list.values
  end

  test 'should support determine if list is empty' do
    assert @playlist.empty?

    @playlist.push([])
    assert @playlist.empty?

    @playlist.push(1, 2)
    assert_not @playlist.empty?
  end

  test 'should support determine if the value was in the list' do
    @playlist.push(1, 2)

    assert @playlist.include? 1
    assert_not @playlist.include? 3
  end

  test 'should support get count from list' do
    assert_equal 0, @playlist.count

    @playlist.push(1, 2)
    assert_equal 2, @playlist.count
  end

  test 'should support replace whole list values' do
    @playlist.push(1, 2)
    @playlist.replace([3, 4])

    assert_equal ['3', '4'], @redis_list.value
  end
end
