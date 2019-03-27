# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_album, except: [:index]

  def index
    @pagy, @albums = pagy_countless(Album.with_attached_image.includes(:artist))
  end

  def show
    @songs = @album.songs.order(:tracknum)
  end

  def play
    @song_ids = @album.songs.ids
    @playlist = Current.user.current_playlist

    @playlist.replace(@song_ids)
    @pagy, @songs = pagy_countless(@playlist.songs, page: 1)
  end

  private

    def find_album
      @album = Album.find(params[:id])
    end
end
