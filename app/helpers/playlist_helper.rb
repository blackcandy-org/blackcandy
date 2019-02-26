# frozen_string_literal: true

module PlaylistHelper
  def playlist_tab_items
    [
      { title: t('label.playlist'), path: playlist_path('current') },
      { title: t('label.collections'), path: song_collections_path },
      { title: t('label.favorites'), path: playlist_path('favorite') }
    ]
  end
end
