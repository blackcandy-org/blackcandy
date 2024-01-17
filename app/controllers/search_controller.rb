# frozen_string_literal: true

class SearchController < ApplicationController
  SEARCH_RESULT_MAX_AMOUNT = 10

  def index
    searched_albums = Album.search(params[:query]).includes(:artist).with_attached_cover_image
    searched_artists = Artist.search(params[:query]).with_attached_cover_image
    searched_playlists = Playlist.search(params[:query])
    searched_songs = Song.search(params[:query]).includes(:artist, :album)

    @albums = searched_albums.limit(SEARCH_RESULT_MAX_AMOUNT).load_async
    @is_all_albums = searched_albums.count <= SEARCH_RESULT_MAX_AMOUNT

    @artists = searched_artists.limit(SEARCH_RESULT_MAX_AMOUNT).load_async
    @is_all_artists = searched_artists.count <= SEARCH_RESULT_MAX_AMOUNT

    @playlists = searched_playlists.limit(SEARCH_RESULT_MAX_AMOUNT).load_async
    @is_all_playlists = searched_playlists.count <= SEARCH_RESULT_MAX_AMOUNT

    @songs = searched_songs.limit(SEARCH_RESULT_MAX_AMOUNT).load_async
    @is_all_songs = searched_songs.count <= SEARCH_RESULT_MAX_AMOUNT
  end
end
