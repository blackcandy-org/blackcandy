# frozen_string_literal: true

class Search::ArtistsController < ApplicationController
  def index
    @pagy, @artists = pagy(Artist.search(params[:query]).with_attached_cover_image)

    if partial_request?
      render partial: "search/artists/page", locals: { artists: @artists, pagy: @pagy }
    end
  end
end
