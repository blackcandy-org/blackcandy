class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string  :name, null: false
      t.string  :album_name
      t.string  :artist_name
      t.float   :length, null: false
      t.integer :tracknum
      t.integer :user_id, index: true, null: false
      t.integer :album_id, index: true

      t.timestamps null: false
    end
  end
end
