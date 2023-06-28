# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Playable

  before_action :require_admin, only: [:update]
  before_action :find_album, except: [:index]
  before_action :get_sort_option, only: [:index]

  def index
    records = Album.includes(:artist)
      .filter_records(filter_params)
      .sort_records(*sort_params)

    @pagy, @albums = pagy(records)
  end

  def show
    @songs = @album.songs.includes(:artist)
    @album.attach_image_from_discogs
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
    @song_ids = Album.find(params[:id]).song_ids
  end

  def after_played
    Current.user.add_album_to_recently_played(@album)
  end

  def filter_params
    params[:filter]&.slice(*Album::VALID_FILTERS)
  end

  def sort_params
    [params[:sort], params[:sort_direction]]
  end

  def get_sort_option
    @sort_option = Album::SORT_OPTION
  end
end
