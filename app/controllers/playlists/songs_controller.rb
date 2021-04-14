# frozen_string_literal: true

class Playlists::SongsController < ApplicationController
  layout 'sidebar'

  before_action :find_playlist
  before_action :find_song, only: [:create, :destroy]

  include Pagy::Backend
  include Playable

  def show
    @pagy, @songs = pagy(@playlist.songs.includes(:artist))

    respond_to do |format|
      format.turbo_stream if params[:page].to_i > 1
      format.html
    end
  end

  def create
    @playlist.playlists_songs.create(song_id: @song.id, position: 1)
    flash.now[:success] = t('success.add_to_playlist')

    # for refresh playlist content, when first song add to playlist
    redirect_to action: 'show' if @playlist.songs.size == 1
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = t('error.already_in_playlist')
  end

  def destroy
    if playlists_songs_params[:clear_all]
      @playlist.songs.clear
    else
      @playlist.songs.destroy(@song)
      flash.now[:success] = t('success.delete_from_playlist')
    end

    # for refresh playlist content, when remove last song from playlist
    redirect_to action: 'show' if @playlist.songs.empty?
  end

  def update
    from_position = Integer(playlists_songs_params[:from_position])
    to_position = Integer(playlists_songs_params[:to_position])

    playlists_song = @playlist.playlists_songs.find_by(position: from_position)
    playlists_song.update(position: to_position)
  end

  private

    def find_playlist
      @playlist = Current.user.playlists.find(params[:playlist_id])
    end

    def find_song
      @song = Song.find(playlists_songs_params[:song_id]) unless playlists_songs_params[:clear_all]
    end

    def find_all_song_ids
      @song_ids = @playlist.song_ids
    end

    def playlists_songs_params
      params.permit(:from_position, :to_position, :clear_all, :song_id)
    end
end
