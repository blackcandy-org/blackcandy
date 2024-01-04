# frozen_string_literal: true

require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    login
    get albums_url

    assert_response :success
  end

  test "should update image for album" do
    album = albums(:album1)
    album_original_image_url = album.image.url

    login users(:admin)
    patch album_url(album), params: {album: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}

    assert_not_equal album_original_image_url, album.reload.image.url
  end

  test "should has error flash when failed to update album" do
    login users(:admin)
    patch album_url(albums(:album1)), params: {album: {image: fixture_file_upload("cover_image.gif", "image/gif")}}

    assert flash[:error].present?
  end

  test "should call album image attach job when show album unless album do not need attach" do
    login

    Setting.update(discogs_token: "fake_token")
    album = albums(:album1)

    assert_not album.has_image?
    assert_not album.unknown?

    assert_enqueued_with(job: AttachImageFromDiscogsJob) do
      get album_url(album)
      assert_response :success
    end
  end
end
