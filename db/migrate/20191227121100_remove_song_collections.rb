class RemoveSongCollections < ActiveRecord::Migration[6.0]
  def change
    drop_table :song_collections, if_exists: true
  end
end
