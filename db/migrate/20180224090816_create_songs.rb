class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string  :name, null: false
      t.string  :file_path, null: false
      t.string  :md5_hash, null: false
      t.float   :length, default: 0.0, null: false
      t.integer :tracknum
      t.integer :album_id, index: true
      t.integer :artist_id, index: true

      t.timestamps null: false
    end
  end
end
