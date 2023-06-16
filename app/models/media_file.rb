# frozen_string_literal: true

class MediaFile
  SUPPORTED_FORMATS = WahWah.support_formats.freeze

  class << self
    def file_paths
      media_path = File.expand_path(Setting.media_path)
      Dir.glob("#{media_path}/**/*.{#{SUPPORTED_FORMATS.join(",")}}", File::FNM_CASEFOLD)
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
      string = "#{file_path}#{File.mtime(file_path) if with_mtime}"
      Digest::MD5.base64digest(string)
    end

    private

    def extract_image_from(tag)
      image = tag.images.first
      return unless image.present?

      image_format = MIME::Type.new(image[:mime_type]).sub_type
      CarrierWaveStringIO.new("cover.#{image_format}", image[:data])
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
  end
end
