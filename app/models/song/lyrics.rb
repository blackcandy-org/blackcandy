# frozen_string_literal: true

module Song::Lyrics
  extend ActiveSupport::Concern

  LYRICS_MAX_LENGTH = 100_000
  ALLOWED_LYRICS_FILE_EXTENSION = ".lrc"

  included do
    attr_reader :lyrics_file

    validates :lyrics, length: { maximum: LYRICS_MAX_LENGTH }, if: -> { lyrics_file.present? }
    validate :format_of_lyrics_file, if: -> { lyrics_file.present? }
  end

  def lyrics_file=(file)
    return if file.blank?

    @lyrics_file = file
    self.lyrics = file.read.force_encoding(Encoding::UTF_8).scrub
  end

  def lyrics_content
    lyrics.presence || external_lyrics_file_content
  end

  def lyrics_lines
    Parser.new(lyrics_content).lines
  end

  private

  def external_lyrics_file_content
    lyrics_file_path = external_lyrics_file_path

    File.read(lyrics_file_path).scrub if lyrics_file_path
  end

  def external_lyrics_file_path
    directory = File.dirname(file_path)
    return unless Dir.exist?(directory)

    lyrics_file_name = "#{File.basename(file_path, ".*")}#{ALLOWED_LYRICS_FILE_EXTENSION}"
    found_file_name = Dir.children(directory).find { |name| name.casecmp?(lyrics_file_name) }

    File.join(directory, found_file_name) if found_file_name
  end

  def format_of_lyrics_file
    extension = File.extname(lyrics_file.original_filename).downcase
    errors.add(:lyrics_file, :invalid_content_type) unless extension == ALLOWED_LYRICS_FILE_EXTENSION
  end
end
