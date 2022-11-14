# frozen_string_literal: true

require "test_helper"

class AttachAlbumImageFromFileJobTest < ActiveJob::TestCase
  teardown do
    albums(:album1).image.remove!
  end

  test "should attach image to album" do
    album = albums(:album1)

    MediaFile.stub(:image, {data: file_fixture("cover_image.jpg").read.force_encoding("BINARY"), format: "jpeg"}) do
      assert_not album.has_image?

      AttachAlbumImageFromFileJob.perform_now(album, file_fixture("cover_image.jpg"))
      assert album.reload.has_image?
    end
  end
end
