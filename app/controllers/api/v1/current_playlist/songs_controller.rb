# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::SongsController < ApiController
      def show
        favorite_playlist = Current.user.favorite_playlist

        @songs = Current.user.current_playlist.songs
          .includes(:artist, :album)
          .joins("Left JOIN playlists_songs T1 ON songs.id = T1.song_id AND T1.playlist_id = #{favorite_playlist.id}")
          .select("songs.*, T1.playlist_id IS NOT NULL as is_favorited")
      end
    end
  end
end
