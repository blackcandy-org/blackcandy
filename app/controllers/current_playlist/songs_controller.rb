# frozen_string_literal: true

class CurrentPlaylist::SongsController < Playlists::SongsController
  private

    def find_playlist
      @playlist = Current.user.current_playlist
    end

    def add_to_playlist
      @current_song = Song.find_by(id: cookies[:current_song_id])
      current_song_position = @playlist.playlists_songs.find_by(song_id: @current_song&.id)&.position.to_i

      @playlist.playlists_songs.create(song_id: @song.id, position: current_song_position + 1)
    end
end
