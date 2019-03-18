# frozen_string_literal: true

class SongsController < ApplicationController
  before_action :require_login

  def index
    @songs = Song.includes(:artist).all
  end

  def show
    @song = Song.select('songs.*, albums.name as album_name, artists.name as artist_name').joins(:artist, :album).find(params[:id])
  end

  def favorite
    Current.user.favorite_playlist.toggle(params[:id])
    head :ok
  end
end
