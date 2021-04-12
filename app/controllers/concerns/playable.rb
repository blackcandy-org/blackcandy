# frozen_string_literal: true

module Playable
  extend ActiveSupport::Concern

  included do
    before_action :find_all_song_ids, only: [:play]
  end

  def play
    raise BlackCandyError::Forbidden if @song_ids.blank?

    @playlist = Current.user.current_playlist
    @playlist.replace(@song_ids)
    @pagy, @songs = pagy_countless(@playlist.songs.includes(:artist))

    redirect_to current_playlist_songs_path(init: true, playable: true)
  end

  private

    def find_all_song_ids
      @song_ids = []
    end
end
