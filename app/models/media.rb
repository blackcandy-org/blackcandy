# frozen_string_literal: true

class Media
  attr_reader :file

  def initialize(file_path)
    @file = MediaFile.new(file_path)
  end

  def attach
    return false if file.has_error
    create_relations
  end

  class << self
    def sync
      media_hashes = MediaFile.file_paths.map do |file_path|
        media = new(file_path)
        media.file.md5_hash if media.attach
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

  private

    def create_relations
      artist = Artist.find_or_create_by(name: file.artist_name)
      album = Album.find_or_create_by(artist: artist, name: file.album_name)

      song = Song.find_or_create_by(md5_hash: file.md5_hash) do |item|
        item.attributes = file.song_info.merge(album: album, artist: artist)
      end

      # Attach image from file to the album.
      AttachAlbumImageFromFileJob.perform_later(album.id, file.file_path) unless album.has_image?

      return true unless song.file_path != file.file_path

      song.update(file_path: file.file_path)
    end
end
