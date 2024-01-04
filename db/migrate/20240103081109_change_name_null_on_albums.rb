class ChangeNameNullOnAlbums < ActiveRecord::Migration[7.1]
  def change
    change_column_null :albums, :name, false
  end
end
