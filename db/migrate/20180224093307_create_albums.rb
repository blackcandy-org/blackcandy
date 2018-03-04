class CreateAlbums < ActiveRecord::Migration[5.2]
  def change
    create_table :albums do |t|
      t.string  :name, null: false
      t.string  :artist_name
      t.integer :artist_id, index: true

      t.timestamps null: false
    end
  end
end
