# frozen_string_literal: true

require "test_helper"

class Dialog::ArtistsControllerTest < ActionDispatch::IntegrationTest
  test "should edit album" do
    login users(:admin)
    get edit_dialog_artist_url(artists(:artist1))

    assert_response :success
  end

  test "should only admin can edit artist" do
    login

    get edit_dialog_artist_url(artists(:artist1))
    assert_response :forbidden

    patch artist_url(artists(:artist1)), params: {artist: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
    assert_response :forbidden
  end

  test "should not edit artist when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get edit_dialog_artist_url(artists(:artist1))
      assert_response :forbidden

      patch artist_url(artists(:artist1)), params: {artist: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
      assert_response :forbidden
    end
  end
end
