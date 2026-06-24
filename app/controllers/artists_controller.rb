# frozen_string_literal: true

class ArtistsController < ApplicationController
  render_in_dialog :edit

  before_action :require_admin, only: [ :edit, :update ]
  before_action :find_artist, except: [ :index ]
  before_action :get_sort_option, only: [ :index ]

  def index
    records = Artist.sort_records(*sort_params).with_attached_cover_image
    @pagy, @artists = pagy(records)
  end

  def show
    @albums = @artist.albums.with_attached_cover_image.load_async
    @appears_on_albums = @artist.appears_on_albums.with_attached_cover_image.load_async
  end

  def edit
  end

  def update
    @artist.update!(artist_params)

    respond_to do |format|
      format.html { redirect_to @artist, notice: t("notice.updated") }
      format.json do
        @albums = @artist.albums.with_attached_cover_image
        render :show
      end
    end
  end

  private

  def artist_params
    params.require(:artist).permit(:cover_image)
  end

  def find_artist
    @artist = Artist.find(params[:id])
  end

  def sort_params
    [ params[:sort], params[:sort_direction] ]
  end

  def get_sort_option
    @sort_option = Artist::SORT_OPTION
  end
end
