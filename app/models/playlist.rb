# frozen_string_literal: true

class Playlist < ApplicationRecord
  validates :name, presence: true, if: :require_name?

  has_and_belongs_to_many :songs, -> { order('playlists_songs.created_at') }
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
