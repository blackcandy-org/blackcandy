# frozen_string_literal: true

# The byte<->time map that makes a Range answerable for a file that has not
# been written yet.
#
# At a fixed bitrate, byte_offset = (bitrate / 8) * seconds. The encoder
# overshoots that by a few hundred bytes because MP3 frames quantise the tail,
# so the declared length carries a margin and the tail is padded with real
# silence frames to land on it exactly.
class Transcoder::ByteRange
  # Measured overshoot is 522-770 bytes across sources from 5 s to 30 min and
  # does not scale with duration. 4 KB is roughly five times the worst case.
  PAD_MARGIN = 4096

  attr_reader :first, :last

  class << self
    def byte_rate(bitrate)
      bitrate * 1000 / 8.0
    end

    def predicted_size(duration, bitrate)
      (byte_rate(bitrate) * duration).floor
    end

    def declared_size(duration, bitrate)
      predicted_size(duration, bitrate) + PAD_MARGIN
    end

    def seconds_at(offset, bitrate)
      offset / byte_rate(bitrate)
    end

    # Returns nil when no range was requested, :unsatisfiable when the range
    # falls outside the resource, or a ByteRange otherwise.
    #
    # Bounded ranges must come back exactly as asked: Safari and AVPlayer open
    # with a small probe such as "bytes=0-1" and are badly confused by a reply
    # that runs to the end of the file.
    def parse(header, size)
      return nil if header.blank?

      match = /\Abytes=(\d*)-(\d*)\z/.match(header.strip)
      return :unsatisfiable if match.nil?

      start_value, end_value = match.captures

      if start_value.empty?
        return :unsatisfiable if end_value.empty?

        length = end_value.to_i
        return :unsatisfiable if length.zero?

        first = [ size - length, 0 ].max
        last = size - 1
      else
        first = start_value.to_i
        return :unsatisfiable if first >= size

        last = end_value.empty? ? size - 1 : [ end_value.to_i, size - 1 ].min
        return :unsatisfiable if last < first
      end

      new(first, last)
    end
  end

  def initialize(first, last)
    @first = first
    @last = last
  end

  def length
    last - first + 1
  end

  def content_range(size)
    "bytes #{first}-#{last}/#{size}"
  end
end
