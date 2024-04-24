# frozen_string_literal: true

class MediaFile
  SUPPORTED_FORMATS = WahWah.support_formats.freeze

  class << self
    def file_paths(media_path)
      return [] if media_path.blank?

      absolute_media_path = File.expand_path(media_path)

      # Because Ruby ignores the FNM_CASEFOLD flag in Dir.glob, case sensitivity depends on your system.
      # So we need another way to make Dir.glob case-insensitive.
      # See here: https://github.com/ruby/ruby/pull/4583
      case_insensitive_supported_formats = SUPPORTED_FORMATS.map do |format|
        format.chars.map { |char| (char.downcase != char.upcase) ? "[#{char.downcase}#{char.upcase}]" : char }.join
      end

      Dir.glob("#{absolute_media_path}/**/*.{#{case_insensitive_supported_formats.join(",")}}")
    end

    def format(file_path)
      File.extname(file_path).downcase.delete(".")
    end

    def file_info(file_path)
      tag_info = get_tag_info(file_path)
      tag_info.merge(
        file_path: file_path.to_s,
        file_path_hash: get_md5_hash(file_path),
        md5_hash: get_md5_hash(file_path, with_mtime: true)
      )
    end

    def get_md5_hash(file_path, with_mtime: false)
      string = "#{file_path}#{File.mtime(file_path) if with_mtime && File.exist?(file_path)}"
      Digest::MD5.base64digest(string)
    end

    private

    def extract_image_from(tag)
      image = tag.images.first
      return unless image.present?

      mime_type = normalize_image_mime_type(image[:mime_type])
      image_format = Mime::Type.lookup(mime_type).symbol
      return unless image_format.present?

      {
        io: StringIO.new(image[:data]),
        filename: "cover.#{image_format}",
        content_type: mime_type
      }
    end

    def get_tag_info(file_path)
      tag = WahWah.open(file_path)

      {
        name: tag.title.presence || File.basename(file_path),
        album_name: tag.album.presence,
        artist_name: tag.artist.presence,
        albumartist_name: tag.albumartist.presence,
        genre: tag.genre.presence,
        tracknum: tag.track,
        discnum: tag.disc,
        duration: tag.duration.round,
        bit_depth: tag.bit_depth,
        image: extract_image_from(tag)
      }.tap do |info|
        info[:year] = begin
          Date.strptime(tag.year, "%Y").year
        rescue
          nil
        end
      end
    end

    def normalize_image_mime_type(mime_type)
      case mime_type
      when "image/jpg"
        "image/jpeg"
      else
        mime_type
      end
    end
  end
end
