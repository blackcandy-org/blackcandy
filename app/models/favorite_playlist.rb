# frozen_string_literal: true

class FavoritePlaylist < Playlist
  def name
    I18n.t("label.favorites")
  end

  private

  def require_name?
    false
  end
end
