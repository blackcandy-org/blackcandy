# frozen_string_literal: true

require "test_helper"

class AttachCoverImageFromDiscogsJobTest < ActiveJob::TestCase
  setup do
    @discogs_client = Minitest::Mock.new

    @discogs_client.expect(
      :cover_image,
      {
        io: StringIO.new(file_fixture("cover_image.jpg").read),
        filename: "cover.jpg",
        content_type: "image/jpeg"
      },
      [ApplicationRecord]
    )
  end

  test "should attach image to album" do
    album = albums(:album1)

    Integrations::Discogs.stub(:new, @discogs_client) do
      assert_not album.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(album)
      assert album.reload.has_cover_image?
    end
  end

  test "should attach image to artist" do
    artist = artists(:artist1)

    Integrations::Discogs.stub(:new, @discogs_client) do
      assert_not artist.has_cover_image?

      AttachCoverImageFromDiscogsJob.perform_now(artist)
      assert artist.reload.has_cover_image?
    end
  end

  test "should retry the job when api request has been rate limited" do
    album = albums(:album1)
    discogs_client = Minitest::Mock.new

    discogs_client.expect(:cover_image, nil) do |_|
      raise Integrations::Service::TooManyRequests
    end

    Integrations::Discogs.stub(:new, discogs_client) do
      assert_enqueued_with(job: AttachCoverImageFromDiscogsJob, args: [album]) do
        AttachCoverImageFromDiscogsJob.perform_now(album)
      end
    end
  end
end
