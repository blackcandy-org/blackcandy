# frozen_string_literal: true

require "test_helper"

class AttachArtistImageFromDiscogsJobTest < ActiveJob::TestCase
  teardown do
    artists(:artist1).image.remove!
  end

  test "should attach image to artist" do
    artist = artists(:artist1)

    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: file_fixture("cover_image.jpg").read, status: 200, headers: {"Content-Type" => "image/jpeg"})

    DiscogsApi.stub(:artist_image, "http://example.com/cover.jpg") do
      assert_not artist.has_image?

      AttachArtistImageFromDiscogsJob.perform_now(artist)
      assert artist.reload.has_image?
    end
  end
end
