# frozen_string_literal: true

class Song::Lyrics::Parser
  TIME_TAG_PATTERN = /\[(\d{1,2}):(\d{1,2})(?:\.(\d{1,3}))?\]/
  WORD_TIME_TAG_PATTERN = /<\d{1,2}:\d{1,2}(?:\.\d{1,3})?>/
  TAG_PATTERN = Regexp.union(TIME_TAG_PATTERN, WORD_TIME_TAG_PATTERN)
  METADATA_LINE_PATTERN = /\A\s*\[(?:ar|ti|al|au|by|offset|re|ve|length):/i
  OFFSET_TAG_PATTERN = /^\[offset:\s*([+-]?\d+)\]/i

  Line = Data.define(:time, :content) do
    def synced?
      !time.nil?
    end
  end

  def initialize(text)
    @text = text.to_s
  end

  def lines
    @lines ||= begin
      synced_lines, plain_lines = parsed_lines.partition(&:synced?)

      synced_lines.presence&.sort_by(&:time) || plain_lines
    end
  end

  private

  def parsed_lines
    @text.each_line.flat_map { |raw_line| parse_line(raw_line) }
  end

  def parse_line(raw_line)
    return [] if raw_line.match?(METADATA_LINE_PATTERN)

    content = raw_line.gsub(TAG_PATTERN, "").strip
    return [] if content.blank?

    line_times(raw_line).map { |time| Line.new(time: time, content: content) }
  end

  def line_times(raw_line)
    raw_line.scan(TIME_TAG_PATTERN).map { |time_tag| time_at(*time_tag) }.presence || [ nil ]
  end

  def time_at(minutes, seconds, fraction)
    [ minutes.to_i * 60 + seconds.to_i + "0.#{fraction}".to_f - offset, 0 ].max
  end

  def offset
    @offset ||= @text[OFFSET_TAG_PATTERN, 1].to_i / 1000.0
  end
end
