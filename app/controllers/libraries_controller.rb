# frozen_string_literal: true

class LibrariesController < ApplicationController
  def show
    @albums_count = Album.count
    @artists_count = Artist.count
    @songs_count = Song.count
    @playlists_count = Current.user.playlists_with_favorite.count
  end
end
