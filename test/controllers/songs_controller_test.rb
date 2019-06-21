# frozen_string_literal: true

require 'test_helper'

class SongsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: songs_url) do
      assert_response :success
    end
  end

  test 'should show song' do
    assert_login_access(url: song_url(songs(:mp3_sample)), xhr: true) do
      assert_response :success
    end
  end

  test 'should toggle favorite song' do
    flush_redis

    user = users(:visitor1)
    song = songs(:mp3_sample)

    assert_login_access(method: :post, user: user, url: favorite_song_url(song)) do
      assert_equal [song.id], user.favorite_playlist.song_ids
    end

    assert_login_access(method: :post, user: user, url: favorite_song_url(song)) do
      assert_equal [], user.favorite_playlist.song_ids
    end
  end

  test 'should show add song' do
    assert_login_access(url: add_song_url(songs :mp3_sample), xhr: true) do
      assert_response :success
    end
  end
end
