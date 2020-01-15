# frozen_string_literal: true

class CurrentPlaylist::SongsController < Playlists::SongsController
  def update
    song_ids = songs_params[:song_ids]
    raise BlackCandyError::Forbidden if song_ids.empty?

    @playlist.songs.clear
    @playlist.song_ids = song_ids; show
  end

  private

    def find_playlist
      @playlist = Current.user.current_playlist
    end
end
