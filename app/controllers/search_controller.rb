# frozen_string_literal: true

class SearchController < ApplicationController
  SEARCH_RESULT_MAX_AMOUNT = 10

  include Pagy::Backend

  def index
    @albums_pagy, @albums = pagy(Album.search(params[:query]).includes(:artist), items: SEARCH_RESULT_MAX_AMOUNT)
    @artists_pagy, @artists = pagy(Artist.search(params[:query]), items: SEARCH_RESULT_MAX_AMOUNT)
    @songs_pagy, @songs = pagy(Song.search(params[:query]).includes(:artist, :album), items: SEARCH_RESULT_MAX_AMOUNT)
  end
end
