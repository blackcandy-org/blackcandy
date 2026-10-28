# frozen_string_literal: true

class Search::AlbumsController < ApplicationController
  def index
    @pagy, @albums = pagy(Album.search(params[:query]).includes(:artist).with_attached_cover_image)

    if partial_request?
      render partial: "search/albums/page", locals: { albums: @albums, pagy: @pagy }
    end
  end
end
