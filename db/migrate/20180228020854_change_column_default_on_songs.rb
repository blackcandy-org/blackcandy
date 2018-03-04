class ChangeColumnDefaultOnSongs < ActiveRecord::Migration[5.2]
  def change
    change_column_default :songs, :name, 'Untitled Track'
    change_column :songs, :album_name, :string, null: false, default: 'Untitled Album'
    change_column :songs, :artist_name, :string, null: false, default: 'Untitled Artist'
  end
end
