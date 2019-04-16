# frozen_string_literal: true

class SongsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    records = Song.includes(:artist, :album).search(params[:query]).order(:name)
    @pagy, @songs = pagy_countless(records)
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
