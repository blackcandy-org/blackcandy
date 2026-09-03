# frozen_string_literal: true

module Transcoder::Ffmpeg
  MUTEX = Mutex.new

  class << self
    def stream_command(source, bitrate, seek: nil, stop: nil)
      command = [ "ffmpeg" ]
      # Input seeking, so a restart lands in milliseconds rather than decoding
      # everything up to the offset first.
      command += [ "-ss", format("%.6f", seek) ] if seek
      # Absolute input timestamp to stop at, so a bounded range lets ffmpeg
      # finish on its own instead of encoding to the end of the track until we
      # kill it.
      command += [ "-to", format("%.6f", stop) ] if stop

      command + [
        "-i", source.to_s,
        "-map", "0:0",
        "-v", "0",
        "-ab", "#{bitrate}k",
        "-f", Transcoder::FORMAT
      ] + muxer_flags + [ "-" ]
    end

    # Song#duration comes from WahWah reading the source tags, which is exact
    # for FLAC and ALAC but approximate for some VBR sources. A 1% duration
    # error is a 48 KB size error, far past any sane pad, so the size
    # prediction reads the duration back off the file itself.
    def duration(path)
      output, status = Open3.capture2(
        "ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path.to_s,
        err: File::NULL
      )
      return nil unless status.success?

      value = output.strip.to_f
      value.positive? ? value : nil
    rescue Errno::ENOENT
      nil
    end

    # Fills exactly `bytes` so the response can land on its declared length.
    #
    # Three things were measured here. Null bytes make strict decoders reject
    # the file outright ("Invalid data found when processing input"). Real
    # silence frames cut short mid-frame are nearly as bad - the decoder
    # reports "invalid new backstep". So the silence stops on a frame boundary
    # and the remainder is an ID3v1 style trailer, which decoders skip the way
    # they skip the tag on millions of existing files.
    def padding(bytes, bitrate)
      return "".b if bytes <= 0

      frames = silence_frames(bytes, bitrate)
      frames + trailer(bytes - frames.bytesize)
    end

    private

    TRAILER_TAG = "TAG"
    FRAME_BITRATES = [ nil, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, nil ].freeze
    FRAME_SAMPLE_RATES = [ 44100, 48000, 32000, nil ].freeze

    def silence_frames(budget, bitrate)
      pool = silence_pool(bitrate)
      return "".b if pool.empty?

      limit = budget - TRAILER_TAG.bytesize
      frames = +"".b
      offset = 0

      while frames.bytesize < limit
        offset = 0 if offset >= pool.bytesize

        length = frame_length(pool.byteslice(offset, 4))
        break if length.nil? || frames.bytesize + length > limit

        frame = pool.byteslice(offset, length)
        break if frame.nil? || frame.bytesize < length

        frames << frame
        offset += length
      end

      frames
    end

    def trailer(size)
      return "".b if size <= 0
      return (" " * size).b if size < TRAILER_TAG.bytesize

      (TRAILER_TAG + " " * (size - TRAILER_TAG.bytesize)).b
    end

    def frame_length(header)
      return nil if header.nil? || header.bytesize < 4

      bytes = header.unpack("C4")
      return nil unless bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0

      bitrate = FRAME_BITRATES[(bytes[2] >> 4) & 0xF]
      sample_rate = FRAME_SAMPLE_RATES[(bytes[2] >> 2) & 0x3]
      return nil if bitrate.nil? || sample_rate.nil?

      (144 * bitrate * 1000 / sample_rate) + ((bytes[2] >> 1) & 1)
    end

    def muxer_flags
      # A pure CBR frame stream with no container headers to account for is
      # what makes the byte<->time map exact rather than approximate.
      [ "-write_xing", "0", "-id3v2_version", "0", "-write_id3v1", "0" ]
    end

    def silence_pool(bitrate)
      MUTEX.synchronize do
        @silence_pool ||= {}
        @silence_pool[bitrate] ||= generate_silence(bitrate)
      end
    end

    def generate_silence(bitrate)
      command = [
        "ffmpeg", "-v", "0", "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo:d=2",
        "-ab", "#{bitrate}k", "-f", Transcoder::FORMAT
      ] + muxer_flags + [ "-" ]

      output, status = Open3.capture2(*command, binmode: true)
      status.success? ? output : "".b
    rescue Errno::ENOENT
      "".b
    end
  end
end
