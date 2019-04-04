# frozen_string_literal: true

class DiscogsAPI
  include HTTParty

  base_uri 'https://api.discogs.com'
  default_params token: Setting.discogs_token

  class << self
    def search(options)
      response = get('/database/search', options)
      response.parsed_response['results'] if response.success?
    end

    def artist_image(artist)
      raise TypeError, 'Expect Artist instance' unless artist.is_a? Artist

      options = { query: { type: 'artist', q: artist.name } }
      get_image(search(options))
    end

    def album_image(album)
      raise TypeError, 'Expect Album instance' unless album.is_a? Album

      options = { query: { type: 'master', release_title: album.name, artist: album.artist.name } }
      get_image(search(options))
    end

    def get_image(response)
      return if response.blank?
      response.first['cover_image']
    end
  end
end
