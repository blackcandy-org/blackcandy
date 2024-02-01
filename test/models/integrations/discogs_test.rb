# frozen_string_literal: true

require "test_helper"

class Integrations::DiscogsTest < ActiveSupport::TestCase
  setup do
    @discogs_client = Integrations::Discogs.new("fake_token")
    @api_response = {results: [{cover_image: "http://example.com/cover.jpg"}]}
    @cover_image_binary = file_fixture("cover_image.jpg").read.force_encoding("BINARY").strip
  end

  test "should get artist image url" do
    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: @cover_image_binary, status: 200, headers: {"Content-Type" => "image/jpeg"})

    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "artist", q: "artist1"}
      )
      .to_return(body: @api_response.to_json, status: 200)

    response = @discogs_client.cover_image(artists(:artist1))

    assert_equal @cover_image_binary, response[:io].read.force_encoding("BINARY").strip
    assert_equal "cover.jpeg", response[:filename]
    assert_equal "image/jpeg", response[:content_type]
  end

  test "should get album image url" do
    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: @cover_image_binary, status: 200, headers: {"Content-Type" => "image/jpeg"})

    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "master", release_title: "album1", artist: "artist1"}
      )
      .to_return(body: @api_response.to_json, status: 200)

    response = @discogs_client.cover_image(albums(:album1))

    assert_equal @cover_image_binary, response[:io].read.force_encoding("BINARY").strip
    assert_equal "cover.jpeg", response[:filename]
    assert_equal "image/jpeg", response[:content_type]
  end

  test "should return nil when pass wrong type params" do
    assert_nil @discogs_client.cover_image(nil)
    assert_nil @discogs_client.cover_image(Song.first)
  end

  test "should raise too many requests error when api request has been rate limited" do
    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(body: @cover_image_binary, status: 200, headers: {"Content-Type" => "image/jpeg"})

    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "master", release_title: "album1", artist: "artist1"}
      )
      .to_return(status: 429)

    assert_raises(Integrations::Service::TooManyRequests) do
      @discogs_client.cover_image(albums(:album1))
    end
  end

  test "should raise too many requests error when download request has been rate limited" do
    stub_request(:get, "http://example.com/cover.jpg")
      .to_return(status: 429)

    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "master", release_title: "album1", artist: "artist1"}
      )
      .to_return(body: @api_response.to_json, status: 200)

    assert_raises(Integrations::Service::TooManyRequests) do
      @discogs_client.cover_image(albums(:album1))
    end
  end
end
