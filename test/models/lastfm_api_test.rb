# frozen_string_literal: true

require "test_helper"

class LastfmApiTest < ActiveSupport::TestCase
  setup do
    Setting.update(lastfm_api_key: "fake_api_key")
  end

  test "should get artist top tracks" do
    api_response = File.read('./test/fixtures/json/lastfm/get_top_tracks.json')

    stub_request(:get, "http://ws.audioscrobbler.com/2.0/")
      .with(query: {api_key: "fake_api_key", format: "json", artist: "artist1", method: "artist.gettoptracks"})
      .to_return(status: 200, body: api_response)

    assert_equal 50, LastfmApi.artist_top_track(artists(:artist1)).count
  end

  test "should handle lastfm error" do
    api_response = File.read('./test/fixtures/json/lastfm/get_top_tracks_error_artist.json')

    stub_request(:get, "http://ws.audioscrobbler.com/2.0/")
      .with(query: {api_key: "fake_api_key", format: "json", artist: "artist1", method: "artist.gettoptracks"})
      .to_return(status: 200, body: api_response)

    assert_equal 0, LastfmApi.artist_top_track(artists(:artist1)).count
  end
end
