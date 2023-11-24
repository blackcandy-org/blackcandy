# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::Songs::AlbumsController < ApiController
      before_action :find_current_playlist
      before_action :find_album
      after_action :add_to_recently_played, only: [:update]

      def update
        @current_playlist.replace(@album.song_ids)
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
  end
end
