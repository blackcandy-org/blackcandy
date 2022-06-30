# frozen_string_literal: true

class FavoritePlaylist < Playlist
  private

  def require_name?
    false
  end
end
