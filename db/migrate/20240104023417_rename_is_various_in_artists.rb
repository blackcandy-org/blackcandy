class RenameIsVariousInArtists < ActiveRecord::Migration[7.1]
  def change
    rename_column :artists, :is_various, :various
  end
end
