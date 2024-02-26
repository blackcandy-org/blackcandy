# frozen_string_literal: true

class AlbumsController < ApplicationController
  before_action :require_admin, only: [:update]
  before_action :find_album, except: [:index]
  before_action :get_sort_option, only: [:index]

  def index
    records = Album.includes(:artist)
      .with_attached_cover_image
      .filter_records(filter_params)
      .sort_records(*sort_params)

    @pagy, @albums = pagy(records)
  end

  def show
    @groped_songs = @album.songs.includes(:artist).group_by(&:discnum)
  end

  def update
    if @album.update(album_params)
      flash[:success] = t("notice.updated")
    else
      flash_errors_message(@album)
    end

    redirect_to @album
  end

  private

  def album_params
    params.require(:album).permit(:cover_image)
  end

  def find_album
    @album = Album.find(params[:id])
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
