class AddRecentlyPlayedAlbumIdsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :recently_played_album_ids, :integer, array: true, default: []
  end
end
