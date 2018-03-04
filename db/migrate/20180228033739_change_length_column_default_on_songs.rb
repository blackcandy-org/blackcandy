class ChangeLengthColumnDefaultOnSongs < ActiveRecord::Migration[5.2]
  def change
    change_column_default :songs, :length, 0
  end
end
