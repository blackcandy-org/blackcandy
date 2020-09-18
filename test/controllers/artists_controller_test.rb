# frozen_string_literal: true

require 'test_helper'

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: artists_url) do
      assert_response :success
    end
  end

  test 'should show artist' do
    assert_login_access(url: artist_url(artists :artist1)) do
      assert_response :success
    end
  end

  test 'should call artist image attach job when show artist unless artist do not need attach' do
    Setting.update(discogs_token: 'fake_token')
    artist = artists(:artist1)
    mock = MiniTest::Mock.new
    mock.expect(:call, true, [artist.id])

    assert_not artist.has_image?
    assert_not artist.is_unknown?

    AttachArtistImageFromDiscogsJob.stub(:perform_later, mock) do
      assert_login_access(url: artist_url(artist)) do
        mock.verify
      end
    end
  end
end
