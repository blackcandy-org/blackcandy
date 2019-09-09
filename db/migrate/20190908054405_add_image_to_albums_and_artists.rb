class AddImageToAlbumsAndArtists < ActiveRecord::Migration[6.0]
  def change
    add_column :albums, :image, :string
    add_column :artists, :image, :string
  end
end
