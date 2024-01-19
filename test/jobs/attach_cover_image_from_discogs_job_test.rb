# frozen_string_literal: true

require "test_helper"

class AttachCoverImageFromDiscogsJobTest < ActiveJob::TestCase
  setup do
    @discogs_client = Integrations::Discogs.new("fake_token")
    @image_resource = {
      io: StringIO.new(file_fixture("cover_image.jpg").read),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    }
  end

  test "should attach image to album" do
    album = albums(:album1)

    @discogs_client.stub(:cover_image, @image_resource) do
      assert_not album.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(album, @discogs_client)
      assert album.reload.has_cover_image?
    end
  end

  test "should attach image to artist" do
    artist = artists(:artist1)

    @discogs_client.stub(:cover_image, @image_resource) do
      assert_not artist.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(artist, @discogs_client)
      assert artist.reload.has_cover_image?
    end
  end
end
