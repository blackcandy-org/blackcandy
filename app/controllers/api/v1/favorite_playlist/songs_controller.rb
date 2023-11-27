# frozen_string_literal: true

module Api
  module V1
    class FavoritePlaylist::SongsController < ApiController
      before_action :find_playlist
      before_action :find_song, only: [:destroy]

      def create
        @song = Song.find(params[:song_id])
        @playlist.playlists_songs.create(song_id: @song.id, position: 1)
      rescue ActiveRecord::RecordNotUnique
        raise BlackCandy::DuplicatePlaylistSong
      end

      def destroy
        @playlist.songs.destroy(@song)
      end

      private

      def find_song
        @song = @playlist.songs.find(params[:id])
      end

      def find_playlist
        @playlist = Current.user.favorite_playlist
      end
    end
  end
end
