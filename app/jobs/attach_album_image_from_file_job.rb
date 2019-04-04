# frozen_string_literal: true

class AttachAlbumImageFromFileJob < ApplicationJob
  queue_as :default

  def perform(album_id, file_path)
    album = Album.find_by(id: album_id)
    file_image = MediaFile.image(file_path)

    return unless album && file_image.present?

    album.image.attach(
      io: StringIO.new(file_image),
      filename: 'cover'
    )
  end
end
