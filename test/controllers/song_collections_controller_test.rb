# frozen_string_literal: true

require 'test_helper'

class SongCollectionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: song_collections_url, xhr: true) do
      assert_response :success
    end
  end

  test 'should create song collection' do
    song_collections_count = SongCollection.count

    assert_login_access(method: :post, url: song_collections_url, params: { song_collection: { name: 'test' } }, xhr: true) do
      assert_equal song_collections_count + 1, SongCollection.count
    end
  end

  test 'should update song collection' do
    song_collection = song_collections(:collection1)
    user = song_collection.user

    assert_login_access(user: user, method: :patch, url: song_collection_url(song_collection), params: { song_collection: { name: 'updated_collection' } }, xhr: true) do
      assert_equal 'updated_collection', song_collection.reload.name
    end
  end

  test 'should destroy song collection' do
    song_collection = song_collections(:collection1)
    user = song_collection.user
    song_collections_count = SongCollection.count

    assert_login_access(user: user, method: :delete, url: song_collection_url(song_collection), xhr: true) do
      assert_equal song_collections_count - 1, SongCollection.count
    end
  end
end
