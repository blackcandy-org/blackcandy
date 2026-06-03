# frozen_string_literal: true

module AlbumHelper
  def album_meta_info(album)
    [ album.genre, album.year ].reject(&:blank?).join(" · ")
  end

  def album_tracks_info(album)
    "#{album.songs.count} #{t("label.tracks")} · #{format_duration(album.songs.sum(:duration))}"
  end
end
