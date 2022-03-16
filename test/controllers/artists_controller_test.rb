# frozen_string_literal: true

require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    assert_login_access(url: artists_url) do
      assert_response :success
    end
  end

  test "should show artist" do
    assert_login_access(url: artist_url(artists(:artist1))) do
      assert_response :success
    end
  end

  test "should edit album" do
    assert_admin_access(url: edit_artist_url(artists(:artist1))) do
      assert_response :success
    end
  end

  test "should update image for album" do
    artist = artists(:artist1)
    artist_params = {artist: {image: fixture_file_upload("cover_image.jpg", "image/jpeg")}}
    artist_original_image_url = artist.image.url

    assert_admin_access(url: artist_url(artist), method: :patch, params: artist_params) do
      assert_not_equal artist_original_image_url, artist.reload.image.url
    end
  end

  test "should call artist image attach job when show artist unless artist do not need attach" do
    Setting.update(discogs_token: "fake_token")
    artist = artists(:artist1)

    assert_not artist.has_image?
    assert_not artist.is_unknown?

    assert_enqueued_with(job: AttachArtistImageFromDiscogsJob) do
      assert_login_access(url: artist_url(artist)) do
        assert_response :success
      end
    end
  end
end
