# frozen_string_literal: true

class Song < ApplicationRecord
  include Searchable

  validates :name, :file_path, :md5_hash, presence: true

  belongs_to :album, touch: true
  belongs_to :artist, touch: true
  has_many :playlists_songs
  has_many :playlists, through: :playlists_songs

  search_by :name, associations: [:artist, :album]

  def format
    file_format = MediaFile.format(file_path)
    file_format.in?(Stream::TRANSCODING_FORMATS) ? Stream::TRANSCODE_FORMAT : file_format
  end
end
