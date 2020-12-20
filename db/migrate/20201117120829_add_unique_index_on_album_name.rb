class AddUniqueIndexOnAlbumName < ActiveRecord::Migration[6.0]
  def change
    add_index :albums, [:artist_id, :name], unique: true
  end
end
