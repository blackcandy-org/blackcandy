# frozen_string_literal: true

class ArtistsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @artists = pagy_countless(Artist.with_attached_image)
  end

  def show
    @artist = Artist.find(params[:id])
    @pagy, @albums = pagy_countless(@artist.albums.with_attached_image)
  end
end
