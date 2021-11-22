# frozen_string_literal: true

class Playlist < ApplicationRecord
  validates :name, presence: true, if: :require_name?

  has_many :playlists_songs
  has_many :songs, -> { order "playlists_songs.position" }, through: :playlists_songs
  belongs_to :user

  def buildin?
    false
  end

  def current?
    type == "CurrentPlaylist"
  end

  def favorite?
    type == "FavoritePlaylist"
  end

  def replace(song_ids)
    songs.clear

    PlaylistsSong.acts_as_list_no_update do
      playlist_songs = song_ids.map.with_index do |song_id, index|
        {song_id: song_id, playlist_id: id, position: index + 1}
      end

      PlaylistsSong.insert_all(playlist_songs)
    end
  end

  private

  def require_name?
    true
  end
end
