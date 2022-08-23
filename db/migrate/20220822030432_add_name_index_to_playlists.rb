class AddNameIndexToPlaylists < ActiveRecord::Migration[7.0]
  def change
    add_index(:playlists, :name)
  end
end
