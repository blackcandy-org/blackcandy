# frozen_string_literal: true

require "open-uri"
class AttachCoverImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(imageable, discogs_client = Integrations::Discogs.new)
    image_url = discogs_client.cover_image(imageable)
    return unless image_url.present?

    image_file = OpenURI.open_uri(image_url)
    content_type = image_file.content_type
    image_format = Mime::Type.lookup(content_type).symbol
    return unless image_format.present?

    imageable.cover_image.attach(
      io: image_file,
      filename: "cover.#{image_format}",
      content_type: content_type
    )
  end
end
