# frozen_string_literal: true

require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    login
    get artists_url

    assert_response :success
  end

  test "should show artist" do
    login
    get artist_url(artists(:artist1))

    assert_response :success
  end

  test "should update image for artist" do
    artist = artists(:artist1)
    artist_original_image_url = artist.image.url

    login users(:admin)
    patch artist_url(artist), params: {artist: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}

    assert_not_equal artist_original_image_url, artist.reload.image.url
  end

  test "should has error flash when failed to update artist" do
    login users(:admin)
    patch artist_url(artists(:artist1)), params: {artist: {image: fixture_file_upload("cover_image.gif", "image/gif")}}

    assert flash[:error].present?
  end

  test "should call artist image attach job when show artist unless artist do not need attach" do
    login

    Setting.update(discogs_token: "fake_token")
    artist = artists(:artist1)

    assert_not artist.has_image?
    assert_not artist.unknown?

    assert_enqueued_with(job: AttachImageFromDiscogsJob) do
      get artist_url(artist)
      assert_response :success
    end
  end
end
