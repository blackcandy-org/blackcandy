class AddDefaultNameToUnknownAlbums < ActiveRecord::Migration[7.1]
  def up
    Album.where(name: [nil, ""]).update_all(name: Album::UNKNOWN_NAME)
  end

  def down
    Album.where(name: Album::UNKNOWN_NAME).update_all(name: nil)
  end
end
