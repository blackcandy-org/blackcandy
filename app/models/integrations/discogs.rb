# frozen_string_literal: true

class Integrations::Discogs < Integrations::Service
  base_uri "https://api.discogs.com"

  def initialize(token = Setting.discogs_token)
    self.class.headers "Authorization" => "Discogs token=#{token}"
  end

  def cover_image(object)
    case object
    when Artist
      artist_cover_image(object)
    when Album
      album_cover_image(object)
    end
  end

  private

  def search_cover_image(options)
    json = request("/database/search", options)
    image_url = json&.dig(:results, 0, :cover_image)
    return unless image_url.present?

    download_image(image_url)
  end

  def artist_cover_image(artist)
    options = {query: {type: "artist", q: artist.name}, format: :plain}
    search_cover_image(options)
  end

  def album_cover_image(album)
    options = {query: {type: "master", release_title: album.name, artist: album.artist.name}, format: :plain}
    search_cover_image(options)
  end
end
