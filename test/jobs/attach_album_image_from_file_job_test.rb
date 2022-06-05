# frozen_string_literal: true

require "test_helper"

class AttachAlbumImageFromFileJobTest < ActiveJob::TestCase
  teardown do
    albums(:album1).image.remove!
  end

  test "should attach image to album when available" do
    album = albums(:album1)

    MediaFile.stub(:image, data: file_fixture("cover_image.jpg").read.force_encoding("BINARY"), format: "jpeg") do
      assert_not album.has_image?

      AttachAlbumImageFromFileJob.perform_now(album, file_fixture("cover_image.jpg"))
      assert album.reload.has_image?

      assert_no_enqueued_jobs
    end
  end

  test "should queue a job to lookup the image from discogs when possible and not found" do
    album = albums(:album1)
    assert_not album.has_image?

    album.stub(:need_attach_from_discogs?, true) do
      assert_enqueued_with(job: AttachAlbumImageFromDiscogsJob, args: [album], queue: "default") do
        AttachAlbumImageFromFileJob.perform_now(album, file_fixture("artist2_album3.oga"))
      end
    end
  end
end
