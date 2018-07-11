# frozen_string_literal: true

class Album < ApplicationRecord
  DEFAULT_NAME = 'Unknown Album'

  validates :name, presence: true
  validates :name, uniqueness: { scope: :artist }

  has_many :songs, dependent: :destroy
  belongs_to :artist

  has_one_attached :image

  def has_image?
    image.attached?
  end

  def self.attach_image(album_id, file_path)
    album = find_by(id: album_id)
    file_image = MediaFile.image(file_path)

    return unless album && file_image.present?

    album.image.attach(
      io: StringIO.new(file_image),
      filename: 'cover'
    )
  end
end
