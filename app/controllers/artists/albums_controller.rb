# frozen_string_literal: true

class Artists::AlbumsController < ApplicationController
  before_action :find_artist
  before_action :find_albums

  def index
    raise BlackCandyError::NotFound if @albums.empty?
  end

  private
    def find_albums
      @albums = @artist.albums
    end

    def find_artist
      @artist = Artist.find(params[:artist_id])
    end
end
