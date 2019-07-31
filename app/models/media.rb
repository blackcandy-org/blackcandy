# frozen_string_literal: true

class Media
  attr_reader :file_info

  def initialize(file_path)
    @file_info = MediaFile.file_info(file_path)
  end

  def attach
    artist = Artist.find_or_create_by(name: file_info[:artist_name])
    album = Album.find_or_create_by(artist: artist, name: file_info[:album_name])

    # Attach image from file to the album.
    AttachAlbumImageFromFileJob.perform_later(album.id, file_info[:file_path]) unless album.has_image?

    Song.find_or_create_by(md5_hash: file_info[:md5_hash]) do |item|
      item.attributes = song_info.merge(album: album, artist: artist)
    end
  rescue
    false
  end

  def song_info
    file_info.slice(:name, :tracknum, :length, :file_path)
  end

  class << self
    def sync
      media_hashes = MediaFile.file_paths.map do |file_path|
        begin
          media = new(file_path)
          media.file_info[:md5_hash] if media.attach
        rescue
          next
        end
      end.compact

      clean_up(media_hashes)
    end

    private

      def clean_up(media_hashes)
        Song.where.not(md5_hash: media_hashes).destroy_all

        # Clean up no content albums and artist.
        Album.left_outer_joins(:songs).where('songs.id is null').destroy_all
        Artist.left_outer_joins(:songs).where('songs.id is null').destroy_all
      end
  end
end
