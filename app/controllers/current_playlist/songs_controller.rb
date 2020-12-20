# frozen_string_literal: true

class CurrentPlaylist::SongsController < Playlists::SongsController
  private

    def find_playlist
      @playlist = Current.user.current_playlist
    end
end
