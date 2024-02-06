class AddUniqueIndexOnSongMd5Hash < ActiveRecord::Migration[7.1]
  def up
    # Remove duplicate songs
    Song.where.not(id: Song.group(:md5_hash).select("min(id)")).destroy_all

    remove_index :songs, :md5_hash
    add_index :songs, :md5_hash, unique: true
  end

  def down
    remove_index :songs, :md5_hash
    add_index :songs, :md5_hash
  end
end
