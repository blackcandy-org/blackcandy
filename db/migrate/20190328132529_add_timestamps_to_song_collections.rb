class AddTimestampsToSongCollections < ActiveRecord::Migration[5.2]
  def change
    add_timestamps(:song_collections, null: false)
  end
end
