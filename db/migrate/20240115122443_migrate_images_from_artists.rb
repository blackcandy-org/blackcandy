class MigrateImagesFromArtists < ActiveRecord::Migration[7.1]
  def up
    Artist.where.not(image: nil).find_each do |artist|
      image_path = Rails.root.join("public", "uploads", "artist", "image", artist.id.to_s, artist.image)
      image_format = File.extname(image_path).downcase.delete(".")

      next unless File.exist?(image_path)

      artist.cover_image.attach(
        io: File.open(image_path),
        filename: "cover.#{image_format}",
        content_type: Mime[image_format]
      )
    end

    remove_column :artists, :image
  end

  def down
    add_column :artists, :image, :string
  end
end
