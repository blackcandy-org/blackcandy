# frozen_string_literal: true

require 'test_helper'

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: albums_url) do
      assert_response :success
    end
  end

  test 'should show album' do
    assert_login_access(url: album_url(albums :album1)) do
      assert_response :success
    end
  end

  test 'should call album image attach job when show album unless album already had image' do
    album = albums(:album1)
    mock = MiniTest::Mock.new
    mock.expect(:call, true, [album.id])

    AttachAlbumImageFromDiscogsJob.stub(:perform_later, mock) do
      assert_login_access(url: album_url(album)) do
        mock.verify
      end
    end
  end

  test 'should play songs from album' do
    flush_redis
    album = albums(:album1)

    assert_login_access(method: :post, url: play_album_url(album), xhr: true) do |logged_user|
      assert_equal album.songs.ids.sort, logged_user.current_playlist.song_ids.sort
    end
  end
end
