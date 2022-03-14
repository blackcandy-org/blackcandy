# frozen_string_literal: true

class Media
  include Singleton
  include Redis::Objects

  value :is_syncing, marshal: true, default: false

  # Redis::Objects will work with any class that provides an id method that returns a unique value.
  # Beacuse this is a Singleton class, so always return same id.
  def id
    Base64.urlsafe_encode64(self.class.name)
  end

  class << self
    def sync
      media_hashes = MediaFile.file_paths.map do |file_path|
        @file_info = MediaFile.file_info(file_path)
        @file_info[:md5_hash] if attach
      rescue
        next
      end.compact

      clean_up(media_hashes)
    end

    def is_syncing?
      instance.is_syncing.value
    end

    def is_syncing=(syncing)
      instance.is_syncing = syncing
    end

    private

    def attach
      artist = Artist.find_or_create_by(name: @file_info[:artist_name])

      if various_artists?
        various_artist = Artist.find_or_create_by(is_various: true)
        album = Album.find_or_create_by(artist: various_artist, name: @file_info[:album_name])
      else
        album = Album.find_or_create_by(artist: artist, name: @file_info[:album_name])
      end

      # Attach image from file to the album.
      AttachAlbumImageFromFileJob.perform_later(album, @file_info[:file_path]) unless album.has_image?

      Song.find_or_create_by(md5_hash: @file_info[:md5_hash]) do |item|
        item.attributes = song_info.merge(album: album, artist: artist)
      end
    rescue
      false
    end

    def song_info
      @file_info.slice(:name, :tracknum, :duration, :file_path)
    end

    def various_artists?
      albumartist = @file_info[:albumartist_name]
      albumartist.present? && (albumartist.casecmp("various artists").zero? || albumartist != @file_info[:artist_name])
    end

    def clean_up(media_hashes)
      Song.where.not(md5_hash: media_hashes).destroy_all

      # Clean up no content albums and artist.
      Album.where.missing(:songs).destroy_all
      Artist.where.missing(:songs, :albums).destroy_all
    end
  end
end
