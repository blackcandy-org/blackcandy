# frozen_string_literal: true

class Playlists::SongsController < ApplicationController
  before_action :find_playlist
  before_action :find_song, only: [ :move, :destroy ]
  before_action :redirect_to_built_in_playlist, only: [ :index ]

  def index
    @pagy, @songs = pagy(@playlist.songs.includes(:artist))
  end

  def create
    @song = Song.find(params[:song_id])
    @playlist.songs.push(@song)

    respond_to do |format|
      format.json { render partial: "songs/song", locals: { song: @song } }
      format.html { redirect_to({ action: "index" }, notice: t("notice.added_to_playlist")) }
    end
  rescue ActiveRecord::RecordNotUnique
    raise BlackCandy::DuplicatePlaylistSong
  end

  def destroy
    @playlist.songs.destroy(@song)

    if @playlist.songs.empty?
      respond_to do |format|
        format.json { render partial: "songs/song", locals: { song: @song } }
        format.html { redirect_to action: "index" }
      end
    else
      respond_to do |format|
        format.json { render partial: "songs/song", locals: { song: @song } }
        format.turbo_stream
      end
    end
  end

  def move
    moving_song = @playlist.playlists_songs.find_by!(song_id: @song.id)
    destination_song = @playlist.playlists_songs.find_by!(song_id: params[:destination_song_id])

    moving_song.insert_at!(destination_song.position)

    respond_to do |format|
      format.html { head :ok }
      format.json { head :no_content }
    end
  end

  def destroy_all
    @playlist.songs.clear

    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to action: "index" }
    end
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
