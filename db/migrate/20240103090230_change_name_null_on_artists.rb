class ChangeNameNullOnArtists < ActiveRecord::Migration[7.1]
  def change
    change_column_null :artists, :name, false
  end
end
