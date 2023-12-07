class AddDiscnumToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :discnum, :integer
  end
end
