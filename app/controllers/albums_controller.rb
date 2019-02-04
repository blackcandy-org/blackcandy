# frozen_string_literal: true

class AlbumsController < ApplicationController
  before_action :require_login

  def index
    @albums = Album.includes(:artist).all
  end

  def show
    @album = Album.find_by(id: params[:id])
  end
end
