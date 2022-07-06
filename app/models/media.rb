# frozen_string_literal: true

class Media
  include Singleton
  include Redis::Objects
  include Turbo::Broadcastable

  extend ActiveModel::Naming

  value :syncing, marshal: true, default: false

  # Redis::Objects will work with any class that provides an id method that returns a unique value.
  # Beacuse this is a Singleton class, so always return same id.
  def id
    Base64.urlsafe_encode64(self.class.name)
  end

  class << self
    def sync(type = :all, file_paths = [])
      file_paths = MediaFile.file_paths if type == :all
      return if file_paths.blank?

      case type
      when :all
        file_hashes = add_files(file_paths)
        clean_up(file_hashes)
      when :added
        add_files(file_paths)
      when :removed
        remove_files(file_paths)
      when :modified
        remove_files(file_paths)
        add_files(file_paths)
      end
    end

    def syncing?
      instance.syncing.value
    end

    def syncing=(is_syncing)
      instance.syncing = is_syncing
      instance.broadcast_render_to "media_sync", partial: "settings/media_sync"
    end

    private

    def add_files(file_paths)
      file_paths.map do |file_path|
        @file_info = MediaFile.file_info(file_path)
        @file_info[:md5_hash] if attach
      rescue
        next
      end.compact
    end

    def remove_files(file_paths)
      file_path_hashes = file_paths.map { |file_path| MediaFile.get_md5_hash(file_path) }
      Song.where(file_path_hash: file_path_hashes).destroy_all

      clean_up
    end

    def attach
      artist = Artist.find_or_create_by!(name: @file_info[:artist_name])

      if various_artists?
        various_artist = Artist.find_or_create_by!(is_various: true)
        album = Album.find_or_create_by!(artist: various_artist, name: @file_info[:album_name])
      else
        album = Album.find_or_create_by!(artist: artist, name: @file_info[:album_name])
      end

      # Attach image from file to the album.
      AttachAlbumImageFromFileJob.perform_later(album, @file_info[:file_path]) unless album.has_image?

      Song.find_or_create_by!(md5_hash: @file_info[:md5_hash]) do |item|
        item.attributes = song_info.merge(album: album, artist: artist)
      end
    end

    def song_info
      @file_info.slice(:name, :tracknum, :duration, :file_path, :file_path_hash)
    end

    def various_artists?
      albumartist = @file_info[:albumartist_name]
      albumartist.present? && (albumartist.casecmp("various artists").zero? || albumartist != @file_info[:artist_name])
    end

    def clean_up(file_hashes = [])
      Song.where.not(md5_hash: file_hashes).destroy_all if file_hashes.present?

      # Clean up no content albums and artist.
      Album.where.missing(:songs).destroy_all
      Artist.where.missing(:songs, :albums).destroy_all
    end
  end
end
