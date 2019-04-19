# frozen_string_literal: true

class MediaFile
  require 'taglib'

  SUPPORT_FORMATE = %w[mp3 ogg m4a flac wav].freeze

  attr_reader :file_path, :md5_hash, :album_name, :artist_name, :has_error

  def initialize(file_path)
    @file_path = file_path

    begin
      set_media_info
      set_md5_hash
    rescue StandardError
      @has_error = true
    end
  end

  def song_info
    instance_values.symbolize_keys.slice(:name, :tracknum, :length, :file_path)
  end

  class << self
    def file_paths
      raise BlackCandyError::InvalidFilePath, I18n.t('error.media_path_blank') unless File.exist?(Setting.media_path)
      raise BlackCandyError::InvalidFilePath, I18n.t('error.media_path_unreadable') unless File.readable?(Setting.media_path)

      Dir.glob("#{Setting.media_path}/**/*.{#{SUPPORT_FORMATE.join(',')}}", File::FNM_CASEFOLD)
    end

    def format(file_path)
      File.extname(file_path).downcase.delete('.')
    end

    def image(file_path)
      case format(file_path)
      when /\A(mp3|m4a)\z/
        get_image_from_mpeg_file(file_path)
      when 'flac'
        get_image_from_flac_file(file_path)
      when 'wav'
        get_image_from_wav_file(file_path)
      else
        false
      end
    end

    private

      def get_image_from_mpeg_file(file_path)
        TagLib::MPEG::File.open(file_path) do |file|
          get_image_from_tag(file.id3v2_tag)
        end
      end

      def get_image_from_flac_file(file_path)
        TagLib::FLAC::File.open(file_path) do |file|
          get_image_from_tag(file.id3v2_tag)
        end
      end

      def get_image_from_wav_file(file_path)
        TagLib::RIFF::WAV::File.open(file_path) do |file|
          get_image_from_tag(file.tag)
        end
      end

      def get_image_from_tag(tag)
        return unless tag
        tag.frame_list('APIC').first&.picture
      end
  end

  private

    def set_media_info
      TagLib::FileRef.open(file_path) do |file|
        raise if file.null?

        tag = file.tag

        @name = tag.title.presence || File.basename(file_path)
        @album_name = tag.album.presence
        @artist_name = tag.artist.presence
        @tracknum = tag.track
        @length = file.audio_properties.length
      end
    end

    def set_md5_hash
      io = File.open(file_path)

      @md5_hash = Digest::MD5.new.tap do |checksum|
        while chunk = io.read(5.megabytes)
          checksum << chunk
        end

        io.rewind
      end.base64digest
    end
end
