class CreateSongCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :song_collections do |t|
      t.string  :name
      t.integer :user_id, index: true
    end
  end
end
