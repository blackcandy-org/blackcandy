# frozen_string_literal: true

class ArtistsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    records = Artist.search(params[:query]).order(:name)
    @pagy, @artists = pagy_countless(records)
  end

  def show
    @artist = Artist.find(params[:id])
    @pagy, @albums = pagy_countless(@artist.albums)

    AttachArtistImageFromDiscogsJob.perform_later(@artist.id) if @artist.need_attach_from_discogs?
  end
end
