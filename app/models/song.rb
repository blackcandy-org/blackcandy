# frozen_string_literal: true

class Song < ApplicationRecord
  include Searchable

  validates :name, :file_path, :file_path_hash, :md5_hash, presence: true

  belongs_to :album, touch: true
  belongs_to :artist, touch: true
  has_many :playlists_songs
  has_many :playlists, through: :playlists_songs

  before_destroy :remove_transcode_cache

  search_by :name, associations: {artist: :name, album: :name}

  def format
    MediaFile.format(file_path)
  end

  private

  def remove_transcode_cache
    cache_directory = "#{Stream::TRANSCODE_CACHE_DIRECTORY}/#{id}"

    return unless Dir.exist?(cache_directory)
    FileUtils.remove_dir(cache_directory)
  end
end
