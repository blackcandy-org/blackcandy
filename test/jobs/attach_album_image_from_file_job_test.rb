# frozen_string_literal: true

require 'test_helper'

class AttachAlbumImageFromFileJobTest < ActiveJob::TestCase
  test 'should attach image to album' do
    album = albums(:album1)

    MediaFile.stub(:image, file_fixture('cover_image.jpg').read.force_encoding('BINARY')) do
      assert_not album.has_image?

      AttachAlbumImageFromFileJob.perform_now(album.id, file_fixture('cover_image.jpg'))
      assert album.reload.has_image?
    end
  end
end
