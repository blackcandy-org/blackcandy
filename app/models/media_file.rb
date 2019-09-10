# frozen_string_literal: true

class MediaFile
  require 'taglib'

  SUPPORT_FORMATE = %w[mp3 ogg opus m4a flac wav].freeze

  class << self
    def file_paths
      media_path = File.expand_path(Setting.media_path)

      raise BlackCandyError::InvalidFilePath, I18n.t('error.media_path_blank') unless File.exist?(media_path)
      raise BlackCandyError::InvalidFilePath, I18n.t('error.media_path_unreadable') unless File.readable?(media_path)

      Dir.glob("#{media_path}/**/*.{#{SUPPORT_FORMATE.join(',')}}", File::FNM_CASEFOLD)
    end

    def format(file_path)
      File.extname(file_path).downcase.delete('.')
    end

    def image(file_path)
      file_path = file_path.to_s

      case format(file_path)
      when 'mp3'
        get_image_from_mp3_file(file_path)
      when 'm4a'
        get_image_from_m4a_file(file_path)
      when 'flac'
        get_image_from_flac_file(file_path)
      when 'wav'
        get_image_from_wav_file(file_path)
      else
        false
      end
    end

    def file_info(file_path)
      tag_info = get_tag_info(file_path)
      tag_info.merge(file_path: file_path, md5_hash: get_md5_hash(file_path))
    end

    private

      def get_image_from_mp3_file(file_path)
        TagLib::MPEG::File.open(file_path) do |file|
          get_image_from_tag(file.id3v2_tag)
        end
      end

      def get_image_from_wav_file(file_path)
        TagLib::RIFF::WAV::File.open(file_path) do |file|
          get_image_from_tag(file.tag)
        end
      end

      def get_image_from_m4a_file(file_path)
        TagLib::MP4::File.open(file_path) do |file|
          return unless file.tag

          tag_image = file.tag.item_list_map['covr'].to_cover_art_list.first

          {
            data: tag_image.data,
            format: tag_image.format == 0x0D ? 'jpeg' : 'png'
          } if tag_image
        end
      end

      def get_image_from_flac_file(file_path)
        TagLib::FLAC::File.open(file_path) do |file|
          tag_image = file.picture_list.first

          {
            data: tag_image.data,
            format: MIME::Type.new(tag_image.mime_type).sub_type
          } if tag_image
        end
      end


      def get_image_from_tag(tag)
        return unless tag

        tag_image = tag.frame_list('APIC').first

        {
          data: tag_image.picture,
          format: MIME::Type.new(tag_image.mime_type).sub_type
        } if tag_image
      end

      def get_tag_info(file_path)
        TagLib::FileRef.open(file_path.to_s) do |file|
          raise if file.null?

          tag = file.tag

          {
            name: tag.title.presence || File.basename(file_path),
            album_name: tag.album.presence,
            artist_name: tag.artist.presence,
            tracknum: tag.track,
            length: file.audio_properties.length
          }
        end
      end

      def get_md5_hash(file_path)
        Digest::MD5.base64digest(file_path.to_s + File.mtime(file_path).to_s)
      end
  end
end
