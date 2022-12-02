# frozen_string_literal: true

class LastfmApi
  include HTTParty

  base_uri "http://ws.audioscrobbler.com"

  class << self
    def search(options)
      default_query = { api_key: Setting.lastfm_api_key, format: 'json' }
      options[:query].merge!(default_query)

      response = get("/2.0/", options)

      JSON.parse response.body, symbolize_names: true if response.success?
    end

    def artist_top_track(artist)
      raise TypeError, "Expect Artist instance" unless artist.is_a? Artist

      options = { query: { method: 'artist.gettoptracks', artist: artist.name }}

      result = search(options)

      return [] if result.blank? || result[:error].present?

      result[:toptracks][:track].each.with_object(:name).map(&:[])
    end
  end
end
