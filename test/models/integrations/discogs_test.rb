# frozen_string_literal: true

require "test_helper"

class Integrations::DiscogsTest < ActiveSupport::TestCase
  setup do
    Setting.update(discogs_token: "fake_token")
    @api_response = {results: [{cover_image: "image_url"}]}
  end

  test "should get artist image url" do
    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "artist", q: "artist1"}
      )
      .to_return(body: @api_response.to_json, status: 200)

    assert_equal "image_url", Integrations::Discogs.cover_image(artists(:artist1))
  end

  test "should get album image url" do
    stub_request(:get, "https://api.discogs.com/database/search")
      .with(
        headers: {"Authorization" => "Discogs token=fake_token"},
        query: {type: "master", release_title: "album1", artist: "artist1"}
      )
      .to_return(body: @api_response.to_json, status: 200)

    assert_equal "image_url", Integrations::Discogs.cover_image(albums(:album1))
  end

  test "should return nil when pass wrong type params" do
    assert_nil Integrations::Discogs.cover_image(nil)
    assert_nil Integrations::Discogs.cover_image(Song.first)
  end
end
