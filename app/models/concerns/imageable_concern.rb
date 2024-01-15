module ImageableConcern
  extend ActiveSupport::Concern

  included do
    has_one_attached :cover_image do |attachable|
      attachable.variant :small, resize_to_fill: [200, 200]
      attachable.variant :medium, resize_to_fill: [300, 300]
      attachable.variant :large, resize_to_fill: [400, 400]
    end
  end

  def has_image?
    cover_image.attached?
  end

  def attach_image_from_discogs
    AttachImageFromDiscogsJob.perform_later(self) if needs_image_from_discogs?
  end

  private

  def needs_image_from_discogs?
    Setting.discogs_token.present? && !has_image? && !unknown?
  end
end
