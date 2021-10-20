# frozen_string_literal: true

class ArtistsController < ApplicationController
  include Pagy::Backend

  layout 'dialog', only: :edit

  before_action :require_admin, only: [:edit, :update]
  before_action :find_artist, except: [:index]

  def index
    records = Artist.order(:name)
    @pagy, @artists = pagy(records)
  end

  def show
    @albums = @artist.albums
    @appears_on_albums = @artist.appears_on_albums

    AttachArtistImageFromDiscogsJob.perform_later(@artist.id) if @artist.need_attach_from_discogs?
  end

  def edit; end

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
