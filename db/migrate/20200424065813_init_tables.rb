class InitTables < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :is_admin, default: false
      t.timestamps
      t.index :email, unique: true
    end

    create_table :albums do |t|
      t.string :name
      t.string :image
      t.timestamps
      t.belongs_to :artist
      t.index :name
    end

    create_table :artists do |t|
      t.string :name
      t.string :image
      t.timestamps
      t.index :name, unique: true
    end

    create_table :playlists do |t|
      t.string :name
      t.string :type
      t.timestamps
      t.belongs_to :user
    end

    create_join_table :playlists, :songs do |t|
      t.index [:song_id, :playlist_id], unique: true
      t.datetime :created_at, null: false
    end

    create_table :songs do |t|
      t.string  :name, null: false
      t.string  :file_path, null: false
      t.string  :md5_hash, null: false
      t.float   :length, default: 0.0, null: false
      t.integer :tracknum
      t.timestamps
      t.belongs_to :album
      t.belongs_to :artist
      t.index :name
    end

    create_table :settings do |t|
      t.string :var, null: false
      t.text :value
      t.integer :thing_id
      t.string :thing_type, limit: 30
      t.timestamps
      t.index [:thing_type, :thing_id, :var], unique: true
    end
  end
end
