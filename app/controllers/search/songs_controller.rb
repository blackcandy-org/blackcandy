# frozen_string_literal: true

class Search::SongsController < ApplicationController
  def index
    @songs = Song.search(params[:query]).includes(:artist, :album)
  end
end
