module ImageableConcern
  extend ActiveSupport::Concern

  ALLOWED_IMAGE_CONTENT_TYPES = %w[image/jpeg image/png].freeze

  included do
    has_one_attached :cover_image do |attachable|
      attachable.variant :small, resize_to_fill: [200, 200]
      attachable.variant :medium, resize_to_fill: [300, 300], preprocessed: true
      attachable.variant :large, resize_to_fill: [400, 400]
    end

    validate :content_type_of_cover_image
  end

  def has_cover_image?
    cover_image.attached?
  end

  def attach_cover_image_from_discogs
    AttachCoverImageFromDiscogsJob.perform_later(self) if needs_cover_image_from_discogs?
  end

  private

  def needs_cover_image_from_discogs?
    Setting.discogs_token.present? && !has_cover_image? && !unknown?
  end

  def content_type_of_cover_image
    return unless cover_image.attached?

    unless cover_image.content_type.in?(ALLOWED_IMAGE_CONTENT_TYPES)
      errors.add(:cover_image, :invalid_content_type)
    end
  end
end
