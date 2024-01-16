# frozen_string_literal: true

require "open-uri"
class AttachCoverImageFromDiscogsJob < ApplicationJob
  queue_as :default

  def perform(discogs_imageable)
    image_url = DiscogsApi.image(discogs_imageable)
    return unless image_url.present?

    image_file = OpenURI.open_uri(image_url)
    content_type = image_file.content_type
    image_format = Mime::Type.lookup(content_type).symbol
    return unless image_format.present?

    discogs_imageable.cover_image.attach(
      io: image_file,
      filename: "cover.#{image_format}",
      content_type: content_type
    )
  end
end
