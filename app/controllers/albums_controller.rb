# frozen_string_literal: true

class AlbumsController < ApplicationController
  render_in_dialog :edit

  before_action :require_admin, only: [ :edit, :update ]
  before_action :find_album, except: [ :index ]
  before_action :get_sort_option, only: [ :index ]

  def index
    records = Album.includes(:artist)
      .with_attached_cover_image
      .filter_records(filter_params)
      .sort_records(*sort_params)

    @pagy, @albums = pagy(records)
  end

  def show
    @songs = @album.songs.includes(:artist)
    @groped_songs = @songs.group_by(&:discnum)
  end

  def edit
  end

  def update
    @album.update!(album_params)

    respond_to do |format|
      format.html { redirect_to @album, notice: t("notice.updated") }
      format.json do
        @songs = @album.songs.includes(:artist)
        render :show
      end
    end
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
    [ params[:sort], params[:sort_direction] ]
  end

  def get_sort_option
    @sort_option = Album::SORT_OPTION
  end
end
