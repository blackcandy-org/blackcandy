# frozen_string_literal: true

class FavoritePlaylist::SongsController < Playlists::SongsController
  private

    def find_playlist
      @playlist = Current.user.favorite_playlist
    end
end
