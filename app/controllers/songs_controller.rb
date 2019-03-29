# frozen_string_literal: true

class SongsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @songs = pagy_countless(Song.includes(:artist, :album))
  end

  def show
    @song = Song.select('songs.*, albums.name as album_name, artists.name as artist_name').joins(:artist, :album).find(params[:id])
  end

  def favorite
    Current.user.favorite_playlist.toggle(params[:id])
    head :ok
  end

  def add
    @pagy, @song_collections = pagy_countless(Current.user.song_collections.order(created_at: :desc))
  end
end
