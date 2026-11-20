# frozen_string_literal: true

class CurrentPlaylist::Songs::PlaylistsController < ApplicationController
  before_action :find_current_playlist
  before_action :find_playlist

  def update
    @current_playlist.replace(@playlist.song_ids)

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

  def find_playlist
    @playlist = Current.user.playlists_with_favorite.find(params[:id])
  end
end
