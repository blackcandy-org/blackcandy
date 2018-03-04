module SpotifyApi
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :name, uniqueness: true, unless: :spotify_id?

    private_class_method :return_album_info, :return_album_info
  end

  class_methods do
    def get_spotify_info(song)
      query = "album:#{song.album_name} + artist:#{song.artist_name}"
      album = RSpotify::Album.search(query).first

      return nil if album.blank?
      return_album_info(album, song) if self == Album
      return_artist_info(album, song) if self == Artist
    end

    def return_album_info(album, song)
      {
        name: song.album_name,
        artist_name: song.artist_name,
        spotify_id: album.id,
        image_url: album.images.first['url']
      }
    end

    def return_artist_info(album, song)
      artist = album.artists.first

      {
        name: song.artist_name,
        spotify_id: artist.id,
        image_url: artist.images.first['url']
      }
    end
  end

  private

  def spotify_id?
    spotify_id.present?
  end
end
