# frozen_string_literal: true

class SongCollection < ApplicationRecord
  include Playlistable

  belongs_to :user
  validates :name, presence: true

  has_playlist

  def tracks_count
    playlist.count
  end
end
