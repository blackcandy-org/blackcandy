# frozen_string_literal: true

class Artist < ApplicationRecord
  UNKNOWN_NAME = "Unknown Artist"
  VARIOUS_NAME = "Various Artists"

  include SearchableConcern
  include ImageableConcern
  include SortableConcern

  after_initialize :set_default_name, if: :new_record?

  validates :name, presence: true

  has_many :albums, dependent: :destroy
  has_many :songs

  search_by :name

  sort_by :name, :created_at

  scope :lack_metadata, -> {
    includes(:cover_image_attachment)
      .where(cover_image_attachment: {id: nil})
      .where.not(name: [Artist::UNKNOWN_NAME, Artist::VARIOUS_NAME])
  }

  def unknown?
    name == UNKNOWN_NAME
  end

  def all_albums
    Album.joins(:songs).where("albums.artist_id = ? OR songs.artist_id = ?", id, id).distinct
  end

  def appears_on_albums
    Album.joins(:songs).where("albums.artist_id != ? AND songs.artist_id = ?", id, id).distinct
  end

  private

  def set_default_name
    self.name ||= various? ? VARIOUS_NAME : UNKNOWN_NAME
  end
end
