# frozen_string_literal: true

class PlaylistsController < ApplicationController
  include Pagy::Backend
  layout "dialog", only: [:new, :edit]

  before_action :find_playlist, only: [:edit, :destroy, :update]

  def index
    @pagy, @playlists = pagy(Current.user.all_playlists.order(created_at: :desc))

    respond_to do |format|
      format.turbo_stream if params[:page].to_i > 1
      format.html
    end
  end

  def new
    @playlist = Playlist.new
  end

  def edit
  end

  def create
    @playlist = Current.user.playlists.new playlist_params

    if @playlist.save
      flash[:success] = t("success.create")
    else
      flash_errors_message(@playlist)
    end

    redirect_to action: "index"
  end

  def update
    if @playlist.update(playlist_params)
      flash[:success] = t("success.update")
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
end
