# frozen_string_literal: true

class Stream
  extend Forwardable

  WEB_SUPPORTED_FORMATS = MediaFile::SUPPORTED_FORMATS - %w[wma]
  SAFARI_SUPPORTED_FORMATS = MediaFile::SUPPORTED_FORMATS - %w[ogg opus oga]
  IOS_SUPPORTED_FORMATS = SAFARI_SUPPORTED_FORMATS
  ANDROID_SUPPORTED_FORMATS = WEB_SUPPORTED_FORMATS

  TRANSCODE_FORMAT = "mp3"

  def_delegators :@song, :file_path, :format

  def initialize(song)
    @song = song
  end
end
