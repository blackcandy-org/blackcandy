# frozen_string_literal: true

require "open-uri"
class AttachCoverImageFromDiscogsJob < ApplicationJob
  retry_on Integrations::Service::TooManyRequests, wait: :polynomially_longer, attempts: :unlimited
  queue_as :default

  def perform(imageable)
    return if imageable.has_cover_image?

    discogs_client = Integrations::Discogs.new
    image_resource = discogs_client.cover_image(imageable)
    return unless image_resource.present?

    imageable.cover_image.attach(image_resource)
  end
end
