# frozen_string_literal: true

class AlbumsController < ApplicationController
  layout "dialog", only: :edit

  before_action :require_admin, only: [:edit, :update]
  before_action :find_album, except: [:index]

  include Pagy::Backend
  include Playable

  def index
    records = Album.includes(:artist).order(:name)
    @pagy, @albums = pagy(records)
  end

  def show
    @songs = @album.songs.includes(:artist)
    @album.attach_image_from_discogs
  end

  def edit
  end

  def update
    if @album.update(album_params)
      flash[:success] = t("success.update")
    else
      flash_errors_message(@album)
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

  def after_played
    Current.user.add_album_to_recently_played(@album)
  end
end
