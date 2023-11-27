# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::SongsController < ApiController
      before_action :find_playlist
      before_action :find_song, only: [:destroy, :move]

      def index
        @songs = @playlist.songs_with_favorite
      end

      def destroy
        @playlist.songs.destroy(@song)
      end

      def move
        moving_song = @playlist.playlists_songs.find_by!(song_id: @song.id)
        destination_song = @playlist.playlists_songs.find_by!(song_id: params[:destination_song_id])

        moving_song.update(position: destination_song.position)
      end

      def create
        @song = Song.find(params[:song_id])

        if params[:location] == "last"
          @playlist.songs.push(@song)
        else
          current_song_position = @playlist.playlists_songs.find_by(song_id: params[:current_song_id])&.position.to_i
          @playlist.playlists_songs.create(song_id: @song.id, position: current_song_position + 1)
        end
      rescue ActiveRecord::RecordNotUnique
        raise BlackCandy::DuplicatePlaylistSong
      end

      def destroy_all
        @playlist.songs.clear
      end

      private

      def find_playlist
        @playlist = Current.user.current_playlist
      end

      def find_song
        @song = @playlist.songs.find(params[:id])
      end
    end
  end
end
