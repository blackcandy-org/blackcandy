class MigrateImagesFromAlbums < ActiveRecord::Migration[7.1]
  def up
    Album.where.not(image: nil).find_each do |album|
      image_path = Rails.root.join("public", "uploads", "album", "image", album.id.to_s, album.image)
      image_format = File.extname(image_path).downcase.delete(".")

      next unless File.exist?(image_path)

      album.cover_image.attach(
        io: File.open(image_path),
        filename: "cover.#{image_format}",
        content_type: Mime[image_format]
      )
    end

    remove_column :albums, :image
  end

  def down
    add_column :albums, :image, :string
  end
end
