class AddTimestampsToSongCollections < ActiveRecord::Migration[6.0]
  def change
    add_timestamps(:song_collections, null: false)
  end
end
