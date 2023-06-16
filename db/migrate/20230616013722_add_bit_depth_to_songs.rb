class AddBitDepthToSongs < ActiveRecord::Migration[7.0]
  def change
    add_column :songs, :bit_depth, :integer
  end
end
