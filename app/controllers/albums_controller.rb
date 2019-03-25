# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @albums = pagy_countless(Album.with_attached_image.includes(:artist), items: 40)
  end

  def show
    @album = Album.includes(:artist, :songs).find(params[:id])
  end

  def play
    @song_ids = Album.find(params[:id]).songs.ids
    @playlist = Current.user.current_playlist

    @playlist.replace(@song_ids)
    @pagy, @songs = pagy_countless(@playlist.songs, page: 1)
  end
end
