# frozen_string_literal: true

class Playlists::SongsController < ApplicationController
  before_action :find_playlist
  before_action :find_song, only: [:move, :destroy]
  before_action :redirect_to_built_in_playlist, only: [:index]

  def index
    @pagy, @songs = pagy(@playlist.songs.includes(:artist))
  end

  def create
    @song = Song.find(params[:song_id])
    @playlist.songs.push(@song)

    flash[:success] = t("notice.added_to_playlist")
  rescue ActiveRecord::RecordNotUnique
    flash[:error] = t("error.already_in_playlist")
  ensure
    redirect_back_with_referer_params(fallback_location: {action: "index"})
  end

  def destroy
    @playlist.songs.destroy(@song)
    flash.now[:success] = t("notice.deleted_from_playlist")

    # for refresh playlist content, when remove last song from playlist
    redirect_to action: "index" if @playlist.songs.empty?
  end

  def move
    moving_song = @playlist.playlists_songs.find_by!(song_id: @song.id)
    destination_song = @playlist.playlists_songs.find_by!(song_id: params[:destination_song_id])

    moving_song.update(position: destination_song.position)
  end

  def destroy_all
    @playlist.songs.clear
    redirect_to action: "index"
  end

  private

  def find_playlist
    @playlist = Current.user.all_playlists.find(params[:playlist_id])
  end

  def find_song
    @song = @playlist.songs.find(params[:id])
  end

  def redirect_to_built_in_playlist
    redirect_to current_playlist_songs_path if @playlist.current?
    redirect_to favorite_playlist_songs_path if @playlist.favorite?
  end
end
