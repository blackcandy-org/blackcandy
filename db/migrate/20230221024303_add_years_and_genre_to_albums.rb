class AddYearsAndGenreToAlbums < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :year, :integer
    add_column :albums, :genre, :string
  end
end
