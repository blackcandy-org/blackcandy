# frozen_string_literal: true

module Song::Lyrics
  extend ActiveSupport::Concern

  LYRICS_FILE_MAX_SIZE = 100.kilobytes
  ALLOWED_LYRICS_FILE_EXTENSION = ".lrc"

  included do
    has_one_attached :lyrics

    validate :format_of_lyrics, :size_of_lyrics, if: -> { lyrics.attached? }
  end

  def external_lyrics_file_path
    directory = File.dirname(file_path)
    return unless Dir.exist?(directory)

    lyrics_file_name = "#{File.basename(file_path, ".*")}#{ALLOWED_LYRICS_FILE_EXTENSION}"
    found_file_name = Dir.children(directory).find { |name| name.casecmp?(lyrics_file_name) }

    File.join(directory, found_file_name) if found_file_name
  end

  private

  def format_of_lyrics
    extension = File.extname(lyrics.filename.to_s).downcase
    errors.add(:lyrics, :invalid_content_type) unless extension == ALLOWED_LYRICS_FILE_EXTENSION
  end

  def size_of_lyrics
    errors.add(:lyrics, :too_large) if lyrics.blob.byte_size > LYRICS_FILE_MAX_SIZE
  end
end
