class AddLyricsToSongs < ActiveRecord::Migration[8.1]
  def change
    add_column :songs, :lyrics, :text
  end
end
