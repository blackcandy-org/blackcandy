class AddSpotifyIdToArtists < ActiveRecord::Migration[5.2]
  def change
    add_column :artists, :spotify_id, :string
    add_index :artists, :spotify_id
  end
end
