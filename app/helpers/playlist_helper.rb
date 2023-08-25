# frozen_string_literal: true

module PlaylistHelper
  def playlist_songs_path(playlist, options = {})
    return current_playlist_songs_path(options) if playlist.current?
    return favorite_playlist_songs_path(options) if playlist.favorite?

    super(playlist, options)
  end
end
