class AddCreateAtToPlaylistsSongs < ActiveRecord::Migration[6.0]
  def change
    add_column :playlists_songs, :created_at, :datetime, null: false
  end
end
