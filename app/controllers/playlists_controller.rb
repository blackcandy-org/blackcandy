# frozen_string_literal: true

class PlaylistsController < ApplicationController
  before_action :find_playlist, only: [ :destroy, :update ]
  before_action :get_sort_option, only: [ :index ]

  def index
    @pagy, @playlists = pagy(Current.user.playlists_with_favorite.sort_records(*sort_params))
  end

  def create
    Playlist.transaction do
      @playlist = Current.user.playlists.create!(playlist_params)
      @playlist.songs.push(Song.find(params[:song_id])) if add_song_to_created_playlist?
    end

    respond_to do |format|
      format.html { redirect_to after_create_path, notice: create_notice }
      format.json { render partial: "playlists/playlist", locals: { playlist: @playlist }, status: :created }
    end
  rescue ActiveRecord::RecordNotUnique
    raise BlackCandy::DuplicatePlaylistSong
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
    params.require(:playlist).permit(:name)
  end

  def after_create_path
    add_song_to_created_playlist? ? playlist_songs_path(@playlist) : { action: "index" }
  end

  def create_notice
    add_song_to_created_playlist? ? t("notice.added_to_playlist") : t("notice.created")
  end

  def add_song_to_created_playlist?
    params[:song_id].present?
  end

  def sort_params
    [ params[:sort], params[:sort_direction] ]
  end

  def get_sort_option
    @sort_option = Playlist::SORT_OPTION
  end
end
