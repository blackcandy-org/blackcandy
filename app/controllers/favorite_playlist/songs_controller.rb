# frozen_string_literal: true

class FavoritePlaylist::SongsController < Playlists::SongsController
  skip_before_action :redirect_to_built_in_playlist

  private

  def find_playlist
    @playlist = Current.user.favorite_playlist
  end
end
