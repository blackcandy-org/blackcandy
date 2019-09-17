class CreateAlbums < ActiveRecord::Migration[6.0]
  def change
    create_table :albums do |t|
      t.string  :name, null: false
      t.integer :artist_id, index: true

      t.timestamps null: false
    end
  end
end
