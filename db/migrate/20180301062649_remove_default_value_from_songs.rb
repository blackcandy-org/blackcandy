class RemoveDefaultValueFromSongs < ActiveRecord::Migration[5.2]
  def change
    change_column_default :songs, :name, nil
    change_column_default :songs, :album_name, nil
    change_column_default :songs, :artist_name, nil
  end
end
