class AddFilePathHashToSongs < ActiveRecord::Migration[7.0]
  def change
    add_column :songs, :file_path_hash, :string
    add_index :songs, :file_path_hash
    add_index :songs, :md5_hash

    reversible do |dir|
      dir.up do
        Song.find_each do |song|
          song.update_column(:file_path_hash, MediaFile.get_md5_hash(song.file_path))
        end
      end
    end
  end
end
