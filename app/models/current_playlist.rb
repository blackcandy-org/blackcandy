# frozen_string_literal: true

class CurrentPlaylist < Playlist
  private

  def require_name?
    false
  end
end
