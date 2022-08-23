# frozen_string_literal: true

class Search::PlaylistsController < ApplicationController
  def index
    @playlists = Playlist.search(params[:query])
  end
end
