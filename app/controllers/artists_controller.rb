# frozen_string_literal: true

class ArtistsController < ApplicationController
  ALBUMS_COUNT = 10

  include Pagy::Backend

  before_action :require_admin, only: [:edit, :update]
  before_action :find_artist, except: [:index]

  def index
    records = Artist.search(params[:query]).order(:name)
    @pagy, @artists = pagy_countless(records)
  end

  def show
    @albums_pagy, @albums = pagy_countless(@artist.albums, items: ALBUMS_COUNT)
    @appears_on_albums_pagy, @appears_on_albums = pagy_countless(@artist.appears_on_albums, items: ALBUMS_COUNT)

    AttachArtistImageFromDiscogsJob.perform_later(@artist.id) if @artist.need_attach_from_discogs?
  end

  def edit
  end

  def update
    if @artist.update(artist_params)
      flash[:success] = t('success.update')
    else
      flash[:error] = @artist.errors.full_messages.join(' ')
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
