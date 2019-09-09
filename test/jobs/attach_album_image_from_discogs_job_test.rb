# frozen_string_literal: true

require 'test_helper'

class AttachAlbumImageFromDiscogsJobTest < ActiveJob::TestCase
  teardown do
    albums(:album1).image.remove!
  end

  test 'should attach image to album' do
    album = albums(:album1)

    stub_request(:get, 'http://example.com/cover.jpg').
      to_return(body: file_fixture('cover_image.jpg').read, status: 200, headers: { 'Content-Type' => 'image/jpeg' })

    DiscogsApi.stub(:album_image, 'http://example.com/cover.jpg') do
      assert_not album.has_image?

      AttachAlbumImageFromDiscogsJob.perform_now(album.id)
      assert album.reload.has_image?
    end
  end
end
