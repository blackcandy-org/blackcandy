# frozen_string_literal: true

class DiscogsApi
  include HTTParty

  base_uri 'https://api.discogs.com'

  class << self
    def search(options)
      default_params token: Setting.discogs_token

      response = get('/database/search', options)
      JSON.parse response, symbolize_names: true if response.success?
    end

    def artist_image(artist)
      raise TypeError, 'Expect Artist instance' unless artist.is_a? Artist

      options = { query: { type: 'artist', q: artist.name }, format: :plain }
      get_image(search(options))
    end

    def album_image(album)
      raise TypeError, 'Expect Album instance' unless album.is_a? Album

      options = { query: { type: 'master', release_title: album.name, artist: album.artist.name }, format: :plain }
      get_image(search(options))
    end

    def get_image(response)
      return if response.blank? || response[:results].blank?
      response[:results].first[:cover_image]
    end
  end
end
