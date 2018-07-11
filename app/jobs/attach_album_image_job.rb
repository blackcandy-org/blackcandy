# frozen_string_literal: true

class AttachAlbumImageJob < ApplicationJob
  queue_as :default

  def perform(album_id, file_path)
    Album.attach_image(album_id, file_path)
  end
end
