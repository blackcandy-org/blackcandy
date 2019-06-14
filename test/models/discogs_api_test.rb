# frozen_string_literal: true

require 'test_helper'

class DiscogsAPITest < ActiveSupport::TestCase
  setup do
    Setting.discogs_token = 'fake_token'
    @api_response = { results: [{ cover_image: 'image_url' }] }
  end

  test 'should get artist image url' do
    stub_request(:get, 'https://api.discogs.com/database/search').
      with(query: { token: 'fake_token', type: 'artist', q: 'artist1' }).
      to_return(body: @api_response.to_json, status: 200)

    assert_equal 'image_url', DiscogsAPI.artist_image(artists(:artist1))
  end

  test 'should get album image url' do
    stub_request(:get, 'https://api.discogs.com/database/search').
      with(query: { token: 'fake_token', type: 'master', release_title: 'album1', artist: 'artist1' }).
      to_return(body: @api_response.to_json, status: 200)

    assert_equal 'image_url', DiscogsAPI.album_image(albums(:album1))
  end

  test 'should raise type error when pass wrong type params' do
    assert_raises TypeError do
      DiscogsAPI.artist_image(nil)
    end

    assert_raises TypeError do
      DiscogsAPI.album_image(nil)
    end
  end
end
