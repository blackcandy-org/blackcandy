# frozen_string_literal: true

class AttachAlbumImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(album_id)
    album = Album.find_by(id: album_id)
    image_url = DiscogsApi.album_image(album)

    return if image_url.blank?

    album.remote_image_url = image_url
    album.save
  end
end
