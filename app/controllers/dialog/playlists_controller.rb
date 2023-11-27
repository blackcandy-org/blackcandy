# frozen_string_literal: true

module Dialog
  class PlaylistsController < DialogController
    def index
      @pagy, @playlists = pagy(Current.user.playlists_with_favorite.order(created_at: :desc))
    end

    def new
      @playlist = Playlist.new
    end

    def edit
      @playlist = Current.user.playlists.find(params[:id])
    end
  end
end
