# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @albums = pagy_countless(Album.with_attached_image.includes(:artist), items: 40)
  end

  def show
    @album = Album.includes(:artist, :songs).find(params[:id])
  end
end
