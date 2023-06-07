# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::SongsController < ApiController
      before_action :find_playlist

      def show
        favorite_playlist = Current.user.favorite_playlist

        @songs = @playlist.songs
          .includes(:artist, :album)
          .joins("Left JOIN playlists_songs T1 ON songs.id = T1.song_id AND T1.playlist_id = #{favorite_playlist.id}")
          .select("songs.*, T1.playlist_id IS NOT NULL as is_favorited")
      end

      def destroy
        if params[:clear_all]
          @playlist.songs.clear
        else
          songs = Song.find(params[:song_ids])
          @playlist.songs.destroy(songs)
        end
      end

      def update
        from_position = Integer(params[:from_position])
        to_position = Integer(params[:to_position])

        playlists_song = @playlist.playlists_songs.find_by(position: from_position)
        playlists_song.update(position: to_position)
      end

      def create
        @song = Song.find(params[:song_id])

        if params[:location] == "last"
          @playlist.songs.push(@song)
        else
          current_song_position = @playlist.playlists_songs.find_by(song_id: params[:current_song_id])&.position.to_i
          @playlist.playlists_songs.create(song_id: @song.id, position: current_song_position + 1)
        end
      end

      private

      def find_playlist
        @playlist = Current.user.current_playlist
      end
    end
  end
end
