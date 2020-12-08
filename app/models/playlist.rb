# frozen_string_literal: true

class Playlist < ApplicationRecord
  validates :name, presence: true, if: :require_name?

  has_many :playlists_songs
  has_many :songs, -> { order 'playlists_songs.position' }, through: :playlists_songs
  belongs_to :user

  def buildin?
    false
  end

  def current?
    type == 'CurrentPlaylist'
  end

  def favorite?
    type == 'FavoritePlaylist'
  end

  private

    def require_name?
      true
    end
end
