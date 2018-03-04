class Artist < ApplicationRecord
  include SpotifyApi

  has_many :albums, dependent: :destroy

  def self.create_or_find_from_song(song)
    artist_info = get_spotify_info(song)

    if artist_info.present?
      find_or_create_by(spotify_id: artist_info[:spotify_id]) do |item|
        item.name = artist_info[:name]
        item.image_url = artist_info[:image_url]
      end
    else
      find_or_create_by(name: song.artist_name)
    end
  end

  def add_album(album)
    return if album.artist_id.present?

    album.artist_id = id
    album.save
  end
end
