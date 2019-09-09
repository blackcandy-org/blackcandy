# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  version :large do
    process resize_to_fill: [400, 400]
  end

  version :medium do
    process resize_to_fill: [300, 300]
  end

  version :small do
    process resize_to_fill: [200, 200]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def content_type_whitelist
    %w(image/jpeg image/png)
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end

  def filename
    if original_filename.present?
      "#{Digest::MD5.hexdigest(original_filename)}.#{file.extension}"
    end
  end

  def default_url(*args)
    default_image_name = ['default', model.class.name.downcase, version_name.presence].compact.join('_')
    "/images/#{default_image_name}.png"
  end
end
