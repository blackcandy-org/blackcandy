# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::Songs::PlaylistsController < ApiController
      before_action :find_current_playlist
      before_action :find_playlist

      def update
        @current_playlist.replace(@playlist.song_ids)
      end

      private

      def find_current_playlist
        @current_playlist = Current.user.current_playlist
      end

      def find_playlist
        @playlist = Current.user.playlists_with_favorite.find(params[:id])
      end
    end
  end
end
