# frozen_string_literal: true

class AttachImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(discogs_imageable)
    image_url = DiscogsApi.image(discogs_imageable)
    discogs_imageable.update(remote_image_url: image_url) if image_url.present?
  end
end
