# frozen_string_literal: true

class FavoritePlaylistsController < PlaylistsController
  private

    def find_playlist
      @playlist = Current.user.favorite_playlist
    end
end
