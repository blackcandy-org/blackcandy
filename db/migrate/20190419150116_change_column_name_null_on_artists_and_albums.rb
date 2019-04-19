class ChangeColumnNameNullOnArtistsAndAlbums < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:albums, :name, true)
    change_column_null(:artists, :name, true)
  end
end
