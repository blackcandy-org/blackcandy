# frozen_string_literal: true

class ArtistsController < ApplicationController
  ALBUMS_COUNT = 10

  include Pagy::Backend

  before_action :require_login

  def index
    records = Artist.search(params[:query]).order(:name)
    @pagy, @artists = pagy_countless(records)
  end

  def show
    @artist = Artist.find(params[:id])
    @albums_pagy, @albums = pagy_countless(@artist.albums, items: ALBUMS_COUNT)
    @appears_on_albums_pagy, @appears_on_albums = pagy_countless(@artist.appears_on_albums, items: ALBUMS_COUNT)

    AttachArtistImageFromDiscogsJob.perform_later(@artist.id) if @artist.need_attach_from_discogs?
  end
end
