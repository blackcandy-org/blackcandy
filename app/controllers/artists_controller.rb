# frozen_string_literal: true

class ArtistsController < ApplicationController
  include Orderable

  layout proc { "dialog" unless turbo_native? }, only: :edit

  before_action :require_admin, only: [:edit, :update]
  before_action :find_artist, except: [:index]

  order_by :name, :created_at

  def index
    records = Artist.order(order_condition)
    @pagy, @artists = pagy(records)
  end

  def show
    @albums = @artist.albums.load_async
    @appears_on_albums = @artist.appears_on_albums.load_async

    @artist.attach_image_from_discogs
  end

  def edit
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
end
