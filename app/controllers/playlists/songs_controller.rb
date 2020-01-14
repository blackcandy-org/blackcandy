# frozen_string_literal: true

class Playlists::SongsController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_playlist
  before_action :find_songs, only: [:create, :destroy]

  def show
    @pagy, @songs = pagy_countless(@playlist.songs.includes(:artist))
  end

  def create
    @playlist.songs.push(@songs)
    flash.now[:success] = t('success.add_to_playlist')

    # for refresh playlist content, when first song add to playlist
    show if @playlist.songs.size == 1
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = t('error.already_in_playlist')
  end

  def destroy
    if songs_params[:clear_all]
      @playlist.songs.clear
    else
      @playlist.songs.destroy(@songs)
      flash.now[:success] = t('success.delete_from_playlist')
    end

    # for refresh playlist content, when remove last song from playlist
    show if @playlist.songs.empty?
  end

  private

    def find_playlist
      @playlist = Current.user.all_playlists.find(songs_params[:playlist_id])
    end

    def find_songs
      @songs = Song.find(songs_params[:song_ids]) unless songs_params[:clear_all]
    end

    def songs_params
      params.permit(:playlist_id, :clear_all, song_ids: [])
    end
end
