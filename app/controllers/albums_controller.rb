# frozen_string_literal: true

class AlbumsController < ApplicationController
  layout 'dialog', only: :edit

  before_action :require_admin, only: [:edit, :update]
  before_action :find_album, except: [:index]

  include Pagy::Backend
  include Playable

  def index
    records = Album.includes(:artist).order(:name)
    @pagy, @albums = pagy(records)

    respond_to do |format|
      format.turbo_stream if params[:page].to_i > 1
      format.html
    end
  end

  def show
    @songs = @album.songs.includes(:artist)
    AttachAlbumImageFromDiscogsJob.perform_later(@album.id) if @album.need_attach_from_discogs?
  end

  def edit; end

  def update
    if @album.update(album_params)
      flash[:success] = t('success.update')
    else
      flash[:error] = @album.errors.full_messages.join(' ')
    end

    redirect_to @album
  end

  private

    def album_params
      params.require(:album).permit(:image)
    end

    def find_album
      @album = Album.find(params[:id])
    end

    def find_all_song_ids
      @song_ids = @album.song_ids
    end
end
