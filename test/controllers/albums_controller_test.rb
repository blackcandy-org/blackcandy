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
    login users(:admin)

    assert_changes -> { album.reload.has_cover_image? } do
      patch album_url(album), params: {album: {cover_image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
    end
  end

  test "should has error flash when failed to update album" do
    login users(:admin)
    patch album_url(albums(:album1)), params: {album: {cover_image: fixture_file_upload("cover_image.gif", "image/gif")}}

    assert flash[:error].present?
  end

  test "should show album" do
    login
    get album_url(albums(:album1))

    assert_response :success
  end
end
