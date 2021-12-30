class RenameLengthToDurationInSongs < ActiveRecord::Migration[6.1]
  def change
    rename_column :songs, :length, :duration
  end
end
