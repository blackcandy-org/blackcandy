module ImageableConcern
  extend ActiveSupport::Concern

  included do
    mount_uploader :image, ImageUploader
  end

  def has_image?
    image.file.present?
  end

  def attach_image_from_discogs
    AttachImageFromDiscogsJob.perform_later(self) if needs_image_from_discogs?
  end

  private

  def needs_image_from_discogs?
    Setting.discogs_token.present? && !has_image? && !is_unknown?
  end
end
