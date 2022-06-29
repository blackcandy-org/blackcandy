# frozen_string_literal: true

require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    login
    get albums_url

    assert_response :success
  end

  test "should show album" do
    login
    get album_url(albums(:album1))

    assert_response :success
  end

  test "should edit album" do
    login users(:admin)
    get edit_album_url(albums(:album1))

    assert_response :success
  end

  test "should update image for album" do
    album = albums(:album1)
    album_original_image_url = album.image.url

    login users(:admin)
    patch album_url(album), params: {album: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}

    assert_not_equal album_original_image_url, album.reload.image.url
  end

  test "should call album image attach job when show album unless album do not need attach" do
    login

    Setting.update(discogs_token: "fake_token")
    album = albums(:album1)

    assert_not album.has_image?
    assert_not album.is_unknown?

    assert_enqueued_with(job: AttachImageFromDiscogsJob) do
      get album_url(album)
      assert_response :success
    end
  end

  test "should play whole album" do
    user = users(:visitor1)

    assert_not_equal albums(:album1).song_ids, user.current_playlist.song_ids

    login user
    post play_album_url(albums(:album1))

    assert_equal albums(:album1).song_ids, user.current_playlist.reload.song_ids
  end

  test "should only admin can edit album" do
    login

    get edit_album_url(albums(:album1))
    assert_response :forbidden

    patch album_url(albums(:album1)), params: {album: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
    assert_response :forbidden
  end
end
