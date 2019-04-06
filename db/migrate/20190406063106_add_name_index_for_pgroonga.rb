class AddNameIndexForPgroonga < ActiveRecord::Migration[5.2]
  def change
    add_index 'songs', 'name', name: 'pgroonga_index_songs_on_name', using: :pgroonga, order: { name: :pgroonga_varchar_full_text_search_ops_v2 }
    add_index 'albums', 'name', name: 'pgroonga_index_albums_on_name', using: :pgroonga, order: { name: :pgroonga_varchar_full_text_search_ops_v2 }
    add_index 'artists', 'name', name: 'pgroonga_index_artists_on_name', using: :pgroonga, order: { name: :pgroonga_varchar_full_text_search_ops_v2 }
  end
end
