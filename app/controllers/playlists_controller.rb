# frozen_string_literal: true

class PlaylistsController < ApplicationController
  render_in_dialog :new, :edit

  before_action :find_playlist, only: [ :edit, :destroy, :update ]
  before_action :get_sort_option, only: [ :index ]

  def index
    @pagy, @playlists = pagy(Current.user.playlists_with_favorite.includes(:playlists_songs).sort_records(*sort_params))
  end

  def new
    @playlist = Playlist.new
  end

  def edit
  end

  def create
    @playlist = Current.user.playlists.create!(playlist_params)

    respond_to do |format|
      format.html { redirect_to action: "index", notice: t("notice.created") }
      format.json { render partial: "playlists/playlist", locals: { playlist: @playlist }, status: :created }
    end
  end

  def update
    @playlist.update!(playlist_params)

    respond_to do |format|
      format.html { redirect_to playlist_songs_path(@playlist), notice: t("notice.updated") }
      format.json { render partial: "playlists/playlist", locals: { playlist: @playlist } }
    end
  end

  def destroy
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to action: "index" }
      format.json { head :no_content }
    end
  end

  private

  def find_playlist
    @playlist = Current.user.playlists.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name, :cover_image)
  end

  def sort_params
    [ params[:sort], params[:sort_direction] ]
  end

  def get_sort_option
    @sort_option = Playlist::SORT_OPTION
  end
end
