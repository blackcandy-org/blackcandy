# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_album, except: [:index]

  def index
    records = Album.search(params[:query]).includes(:artist).order(:name)
    @pagy, @albums = pagy_countless(records)
  end

  def show
    @songs = @album.songs

    AttachAlbumImageFromDiscogsJob.perform_later(@album.id) if @album.need_attach_from_discogs?
  end

  private

    def find_album
      @album = Album.find(params[:id])
    end
end
