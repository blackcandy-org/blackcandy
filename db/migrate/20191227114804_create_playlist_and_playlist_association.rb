class CreatePlaylistAndPlaylistAssociation < ActiveRecord::Migration[6.0]
  def change
    create_table :playlists do |t|
      t.string  :name
      t.string  :type
      t.belongs_to :user
      t.timestamps
    end

    create_table :playlists_songs, id: false do |t|
      t.belongs_to :song
      t.belongs_to :playlist
    end

    add_index :playlists_songs, [:song_id, :playlist_id], unique: true
  end
end
