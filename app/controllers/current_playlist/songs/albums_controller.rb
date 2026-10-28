# frozen_string_literal: true

class CurrentPlaylist::Songs::AlbumsController < ApplicationController
  before_action :find_current_playlist
  before_action :find_album
  after_action :add_to_recently_played, only: [ :update ]

  def update
    @current_playlist.replace(@album.song_ids)

    respond_to do |format|
      format.json
      format.html do
        redirect_to current_playlist_songs_path(
          should_play: params[:should_play],
          song_id: params[:song_id]
        ), status: :see_other
      end
    end
  end

  private

  def find_current_playlist
    @current_playlist = Current.user.current_playlist
  end

  def find_album
    @album = Album.find(params[:id])
  end

  def add_to_recently_played
    Current.user.add_album_to_recently_played(@album)
  end
end
