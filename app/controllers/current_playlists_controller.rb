# frozen_string_literal: true

class CurrentPlaylistsController < PlaylistsController
  before_action :find_playlist

  def create
    song_ids = current_playlist_params[:song_ids]
    raise BlackCandyError::Forbidden if song_ids.empty?

    @playlist.song_ids = song_ids; show
  end

  private

    def current_playlist_params
      params.permit(song_ids: [])
    end

    def find_playlist
      @playlist = Current.user.current_playlist
      @favorite_playlist = Current.user.favorite_playlist if params[:init]
    end
end
