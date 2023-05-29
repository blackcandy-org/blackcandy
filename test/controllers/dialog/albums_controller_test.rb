# frozen_string_literal: true

require "test_helper"

class Dialog::AlbumsControllerTest < ActionDispatch::IntegrationTest
  test "should edit album" do
    login users(:admin)
    get edit_dialog_album_url(albums(:album1))

    assert_response :success
  end

  test "should only admin can edit album" do
    login

    get edit_dialog_album_url(albums(:album1))
    assert_response :forbidden

    patch album_url(albums(:album1)), params: {album: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
    assert_response :forbidden
  end

  test "should not edit album when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get edit_dialog_album_url(albums(:album1))
      assert_response :forbidden

      patch album_url(albums(:album1)), params: {album: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
      assert_response :forbidden
    end
  end
end
