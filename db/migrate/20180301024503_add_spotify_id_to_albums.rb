class AddSpotifyIdToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :spotify_id, :string
    add_index :albums, :spotify_id
  end
end
