# frozen_string_literal: true

class Search::AlbumsController < ApplicationController
  def index
    @albums = Album.search(params[:query]).includes(:artist).with_attached_cover_image
  end
end
