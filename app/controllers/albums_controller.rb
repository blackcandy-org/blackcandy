# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_album, except: [:index]

  def index
    records = Album.includes(:artist).search(params[:query]).order(:name)
    @pagy, @albums = pagy_countless(records)
  end

  def show
    @songs = @album.songs.order(:tracknum)

    AttachAlbumImageFromDiscogsJob.perform_later(@album.id) if @album.need_attach_from_discogs?
  end

  def play
    @song_ids = @album.songs.order(:tracknum).ids
    @playlist = Current.user.current_playlist

    @playlist.replace(@song_ids)
    @pagy, @songs = pagy_countless(@playlist.songs, page: 1)
  end

  private

    def find_album
      @album = Album.find(params[:id])
    end
end
