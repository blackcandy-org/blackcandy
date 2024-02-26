# frozen_string_literal: true

class PlaylistsController < ApplicationController
  before_action :find_playlist, only: [:destroy, :update]
  before_action :get_sort_option, only: [:index]

  def index
    @pagy, @playlists = pagy(Current.user.playlists_with_favorite.sort_records(*sort_params))
  end

  def create
    @playlist = Current.user.playlists.new playlist_params

    if @playlist.save
      flash[:success] = t("notice.created")
    else
      flash_errors_message(@playlist)
    end

    redirect_to action: "index"
  end

  def update
    if @playlist.update(playlist_params)
      flash[:success] = t("notice.updated")
    else
      flash_errors_message(@playlist)
    end

    redirect_to playlist_songs_path(@playlist)
  end

  def destroy
    @playlist.destroy

    redirect_to action: "index"
  end

  private

  def find_playlist
    @playlist = Current.user.playlists.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name)
  end

  def sort_params
    [params[:sort], params[:sort_direction]]
  end

  def get_sort_option
    @sort_option = Playlist::SORT_OPTION
  end
end
