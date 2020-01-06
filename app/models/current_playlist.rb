# frozen_string_literal: true

class CurrentPlaylist < Playlist
  def buildin?
    true
  end

  private

    def require_name?
      false
    end
end
