# frozen_string_literal: true

require "test_helper"

class AttachAlbumImageFromDiscogsJobTest < ActiveJob::TestCase
  setup do
    @discogs_client = Integrations::Discogs.new("fake_token")
  end

  test "should attach image to album" do
    album = albums(:album1)

    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: file_fixture("cover_image.jpg").read, status: 200, headers: {"Content-Type" => "image/jpeg"})

    @discogs_client.stub(:cover_image, "http://example.com/cover.jpg") do
      assert_not album.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(album, @discogs_client)
      assert album.reload.has_cover_image?
    end
  end

  test "should attach image to artist" do
    artist = artists(:artist1)

    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: file_fixture("cover_image.jpg").read, status: 200, headers: {"Content-Type" => "image/jpeg"})

    @discogs_client.stub(:cover_image, "http://example.com/cover.jpg") do
      assert_not artist.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(artist, @discogs_client)
      assert artist.reload.has_cover_image?
    end
  end
end
