class ChangeColumnNameNullOnArtistsAndAlbums < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:albums, :name, true)
    change_column_null(:artists, :name, true)
  end
end
