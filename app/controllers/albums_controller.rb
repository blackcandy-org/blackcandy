# frozen_string_literal: true

class AlbumsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @albums = pagy_countless(Album.includes(:artist), items: 40)
  end

  def show
    @album = Album.find_by(id: params[:id])
  end
end
