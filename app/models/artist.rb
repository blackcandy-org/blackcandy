# frozen_string_literal: true

class Artist < ApplicationRecord
  include Searchable
  include Imageable

  has_many :albums, dependent: :destroy
  has_many :songs

  search_by :name

  def title
    return I18n.t("text.various_artists") if is_various?
    return I18n.t("text.unknown_artist") if is_unknown?

    name
  end

  def is_unknown?
    name.blank?
  end

  def all_albums
    Album.joins(:songs).where("albums.artist_id = ? OR songs.artist_id = ?", id, id).distinct
  end

  def appears_on_albums
    Album.joins(:songs).where("albums.artist_id != ? AND songs.artist_id = ?", id, id).distinct
  end
end
