# frozen_string_literal: true

class CurrentPlaylist < Playlist
  def songs_with_favorite
    favorite_playlist = Current.user.favorite_playlist

    songs.includes(:artist, :album)
      .joins("Left JOIN playlists_songs T1 ON songs.id = T1.song_id AND T1.playlist_id = #{favorite_playlist.id}")
      .select("songs.*, T1.playlist_id IS NOT NULL as is_favorited")
  end

  private

  def require_name?
    false
  end
end
