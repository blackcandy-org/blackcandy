class AddDefaultNameToArtists < ActiveRecord::Migration[7.1]
  def up
    Artist.where(is_various: true).update_all(name: Artist::VARIOUS_NAME)
    Artist.where(name: [nil, ""]).update_all(name: Artist::UNKNOWN_NAME)
  end

  def down
    Artist.where(name: [Artist::UNKNOWN_NAME, Artist::VARIOUS_NAME]).update_all(name: nil)
  end
end
