# frozen_string_literal: true

class AttachAlbumImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(album_id)
    return if Setting.discogs_token.blank?

    album = Album.find_by(id: album_id)
    image_url = DiscogsAPI.album_image(album)

    return unless image_url.present?

    album.image.attach(
      io: open(image_url),
      filename: 'cover'
    )
  end
end
