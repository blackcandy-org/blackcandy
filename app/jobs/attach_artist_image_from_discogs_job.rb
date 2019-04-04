# frozen_string_literal: true

class AttachArtistImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(artist_id)
    artist = Artist.find_by(id: artist_id)
    image_url = DiscogsAPI.artist_image(artist)

    return unless image_url.present?

    artist.image.attach(
      io: open(image_url),
      filename: 'cover'
    )
  end
end
