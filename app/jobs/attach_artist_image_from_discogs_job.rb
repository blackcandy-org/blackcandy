# frozen_string_literal: true

class AttachArtistImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(artist_id)
    artist = Artist.find_by(id: artist_id)
    image_url = DiscogsApi.artist_image(artist)

    return unless image_url.present?

    artist.remote_image_url = image_url
    artist.save
  end
end
