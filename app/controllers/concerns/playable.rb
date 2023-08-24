# frozen_string_literal: true

module Playable
  extend ActiveSupport::Concern

  included do
    before_action :find_all_song_ids, only: [:play]
    after_action :after_played, only: [:play]
  end

  def play
    raise BlackCandy::Error::Forbidden if @song_ids.blank?

    @playlist = Current.user.current_playlist
    @playlist.replace(@song_ids)

    unless turbo_native?
      @pagy, @songs = pagy(@playlist.songs.includes(:artist))
      redirect_to current_playlist_songs_path(playable: true)
    end
  end

  private

  def find_all_song_ids
    raise NotImplementedError
  end

  def after_played
  end
end
