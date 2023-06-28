# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :require_admin, only: [:update]
  before_action :find_artist, except: [:index]
  before_action :get_sort_option, only: [:index]

  def index
    records = Artist.sort_records(*sort_params)
    @pagy, @artists = pagy(records)
  end

  def show
    @albums = @artist.albums.load_async
    @appears_on_albums = @artist.appears_on_albums.load_async

    @artist.attach_image_from_discogs
  end

  def update
    if @artist.update(artist_params)
      flash[:success] = t("success.update")
    else
      flash_errors_message(@artist)
    end

    redirect_to @artist
  end

  private

  def artist_params
    params.require(:artist).permit(:image)
  end

  def find_artist
    @artist = Artist.find(params[:id])
  end

  def sort_params
    [params[:sort], params[:sort_direction]]
  end

  def get_sort_option
    @sort_option = Artist::SORT_OPTION
  end
end
