# frozen_string_literal: true

class Search::PlaylistsController < ApplicationController
  def index
    @pagy, @playlists = pagy(Playlist.search(params[:query]))

    if partial_request?
      render partial: "search/playlists/page", locals: { playlists: @playlists, pagy: @pagy }
    end
  end
end
