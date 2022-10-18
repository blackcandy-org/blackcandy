# frozen_string_literal: true

module Playable
  extend ActiveSupport::Concern

  included do
    before_action :find_all_song_ids, only: [:play]
    after_action :after_played, only: [:play]
  end

  def play
    raise BlackCandyError::Forbidden if @song_ids.blank?

    @playlist = Current.user.current_playlist
    @playlist.replace(@song_ids)
    @pagy, @songs = pagy(@playlist.songs.includes(:artist))

    if turbo_native?
      render turbo_stream: stream_js { "window.NativeBridge.playAll()" }
    else
      redirect_to current_playlist_songs_path(init: true, playable: true)
    end
  end

  private

  def find_all_song_ids
    raise NotImplementedError
  end

  def after_played
  end
end
