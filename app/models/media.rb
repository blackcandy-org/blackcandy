# frozen_string_literal: true

class Media
  include Singleton
  include Turbo::Broadcastable

  extend ActiveModel::Naming

  @@syncing = false

  class << self
    def sync(type = :all, file_paths = [])
      self.syncing = true
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
    ensure
      self.syncing = false
    end

    def syncing?
      @@syncing
    end

    def syncing=(is_syncing)
      @@syncing = is_syncing
      instance.broadcast_render_to "media_sync", partial: "settings/media_sync"
    end

    private

    def add_files(file_paths)
      file_paths.map do |file_path|
        file_info = MediaFile.file_info(file_path)
        file_info[:md5_hash] if attach(file_info)
      rescue
        next
      end.compact
    end

    def remove_files(file_paths)
      file_path_hashes = file_paths.map { |file_path| MediaFile.get_md5_hash(file_path) }
      Song.where(file_path_hash: file_path_hashes).destroy_all

      clean_up
    end

    def attach(file_info)
      artist = Artist.find_or_create_by!(name: file_info[:artist_name])

      album = if various_artist?(file_info)
        various_artist = Artist.find_or_create_by!(is_various: true)
        Album.find_or_initialize_by(artist: various_artist, name: file_info[:album_name])
      else
        Album.find_or_initialize_by(artist: artist, name: file_info[:album_name])
      end

      album.update!(album_info(file_info))
      album.update!(image: file_info[:image]) unless album.has_image?

      song = Song.find_or_initialize_by(md5_hash: file_info[:md5_hash])
      song.update!(song_info(file_info).merge(album: album, artist: artist))
    end

    def song_info(file_info)
      file_info.slice(:name, :tracknum, :duration, :file_path, :file_path_hash, :bit_depth).compact
    end

    def album_info(file_info)
      file_info.slice(:year, :genre).compact
    end

    def various_artist?(file_info)
      albumartist = file_info[:albumartist_name]
      albumartist.present? && (albumartist.casecmp("various artists").zero? || albumartist != file_info[:artist_name])
    end

    def clean_up(file_hashes = [])
      Song.where.not(md5_hash: file_hashes).destroy_all if file_hashes.present?

      # Clean up no content albums and artist.
      Album.where.missing(:songs).destroy_all
      Artist.where.missing(:songs, :albums).destroy_all
    end
  end
end
