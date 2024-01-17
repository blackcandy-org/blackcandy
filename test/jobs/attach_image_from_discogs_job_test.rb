# frozen_string_literal: true

require "test_helper"

class AttachAlbumImageFromDiscogsJobTest < ActiveJob::TestCase
  test "should attach image to album" do
    album = albums(:album1)

    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: file_fixture("cover_image.jpg").read, status: 200, headers: {"Content-Type" => "image/jpeg"})

    DiscogsApi.stub(:album_image, "http://example.com/cover.jpg") do
      assert_not album.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(album)
      assert album.reload.has_cover_image?
    end
  end

  test "should attach image to artist" do
    artist = artists(:artist1)

    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: file_fixture("cover_image.jpg").read, status: 200, headers: {"Content-Type" => "image/jpeg"})

    DiscogsApi.stub(:artist_image, "http://example.com/cover.jpg") do
      assert_not artist.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(artist)
      assert artist.reload.has_cover_image?
    end
  end
end
