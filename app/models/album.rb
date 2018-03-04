class Album < ApplicationRecord
  include SpotifyApi

  has_many :songs, dependent: :destroy
  belongs_to :artist

  def self.create_or_find_from_song(song)
    album_info = get_spotify_info(song)

    if album_info.present?
      find_or_create_by(spotify_id: album_info[:spotify_id]) do |item|
        item.name = album_info[:name]
        item.artist_name = album_info[:artist_name]
        item.image_url = album_info[:image_url]
      end
    else
      find_or_create_by(name: song.album_name)
    end
  end

  def add_song(song)
    song.album_id = id if song.album_id.blank?
  end
end
