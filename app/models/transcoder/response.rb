# frozen_string_literal: true

# Writes the HTTP response onto a hijacked socket.
#
# There is no HTTP server framework on either side of this: the socket has been
# taken away from Puma, so the status line and headers are written by hand.
class Transcoder::Response
  # A restart measures flat at 34-40 ms whatever the offset, so waiting only
  # wins when the write head is closer than that.
  RESTART_LATENCY = 0.04
  HEAD_WAIT_TIMEOUT = 30
  CHUNK_SIZE = 64 * 1024

  STATUS_TEXT = {
    200 => "OK",
    206 => "Partial Content",
    416 => "Range Not Satisfiable"
  }.freeze

  def initialize(song:, bitrate:, range: nil)
    @song = song
    @bitrate = bitrate
    @range_header = range
  end

  def write_to(io)
    cache_key = Transcoder::Cache.key(@song, @bitrate)
    size = resource_size(cache_key)

    # No reliable duration means no reliable size, so that track streams
    # without a length and gives up seeking rather than lying about either.
    return write_chunked(io) if size.nil?

    range = Transcoder::ByteRange.parse(@range_header, size)

    return write_unsatisfiable(io, size) if range == :unsatisfiable

    partial = !range.nil?
    range ||= Transcoder::ByteRange.new(0, size - 1)

    write_headers(
      io,
      status: partial ? 206 : 200,
      length: range.length,
      content_range: partial ? range.content_range(size) : nil
    )

    write_body(io, cache_key, range)
  end

  private

  # A published entry was padded to its declared length, so its size on disk is
  # that length. Only a miss has to probe the source, which costs an ffprobe.
  def resource_size(cache_key)
    cached_size(cache_key) || predicted_size
  end

  def cached_size(cache_key)
    File.size(Transcoder::Cache.path(cache_key))
  rescue Errno::ENOENT
    nil
  end

  def predicted_size
    duration = source_duration
    duration && Transcoder::ByteRange.declared_size(duration, @bitrate)
  end

  def source_duration
    return @source_duration if defined?(@source_duration)

    @source_duration = Transcoder::Ffmpeg.duration(@song.file_path)
  end

  def write_body(io, cache_key, range)
    if Transcoder::Cache.complete?(cache_key)
      Transcoder::Cache.touch(cache_key)
      return stream_file(io, Transcoder::Cache.path(cache_key), range)
    end

    duration = source_duration
    return if duration.nil?

    encode = Transcoder::Cache.encode_for(song: @song, bitrate: @bitrate, duration: duration)

    if restart?(encode, range)
      stream_restart(io, range)
    else
      stream_following_head(io, encode, range)
    end
  end

  # One byte offset, three resolutions: behind the head, read it now; just
  # ahead, wait for it; far ahead, a second encoder started at the offset gets
  # there sooner.
  def restart?(encode, range)
    return false if range.first.zero?

    head = encode.head
    return false if range.first < head

    rate = encode.rate
    return true if rate.zero?

    (range.first - head) / rate > RESTART_LATENCY
  end

  def stream_file(io, path, range)
    File.open(path, "rb") do |file|
      file.seek(range.first)
      copy(io, file, range.length)
    end
  end

  def stream_following_head(io, encode, range)
    position = range.first
    remaining = range.length
    source = open_encode_file(encode)

    while remaining.positive?
      available = encode.head

      if position < available
        source.seek(position)
        chunk = source.read([ CHUNK_SIZE, remaining, available - position ].min)
        break if chunk.nil? || chunk.empty?

        io.write(chunk)
        position += chunk.bytesize
        remaining -= chunk.bytesize
      elsif encode.settled?
        break
      else
        encode.wait_for(position, timeout: HEAD_WAIT_TIMEOUT)
      end
    end
  ensure
    source&.close
  end

  # The encode may publish between the check and the open, in which case the
  # part file is already gone and the finished entry is what we want.
  def open_encode_file(encode)
    File.open(encode.part_path, "rb")
  rescue Errno::ENOENT
    File.open(encode.final_path, "rb")
  end

  def stream_restart(io, range)
    seconds = Transcoder::ByteRange.seconds_at(range.first, @bitrate)
    stop = Transcoder::ByteRange.seconds_at(range.last + 1, @bitrate)
    remaining = range.length
    Transcoder.restart_semaphore.acquire

    begin
      command = Transcoder::Ffmpeg.stream_command(@song.file_path, @bitrate, seek: seconds, stop: stop)

      IO.popen(command, "rb") do |ffmpeg|
        while remaining.positive? && (chunk = ffmpeg.read([ CHUNK_SIZE, remaining ].min))
          io.write(chunk)
          remaining -= chunk.bytesize
        end

        terminate(ffmpeg)
      end
    ensure
      Transcoder.restart_semaphore.release
    end

    # The declared length is authoritative; a restart that lands slightly short
    # of it is made up with silence rather than left hanging.
    io.write(Transcoder::Ffmpeg.padding(remaining, @bitrate)) if remaining.positive?
  end

  def terminate(ffmpeg)
    Process.kill("TERM", ffmpeg.pid)
  rescue Errno::ESRCH, Errno::EPERM
    nil
  end

  def copy(io, source, length)
    remaining = length

    while remaining.positive?
      chunk = source.read([ CHUNK_SIZE, remaining ].min)
      break if chunk.nil? || chunk.empty?

      io.write(chunk)
      remaining -= chunk.bytesize
    end
  end

  def write_chunked(io)
    io.write(
      "HTTP/1.1 200 OK\r\n" \
      "Content-Type: #{Transcoder::CONTENT_TYPE}\r\n" \
      "Transfer-Encoding: chunked\r\n" \
      "Connection: close\r\n\r\n"
    )

    IO.popen(Transcoder::Ffmpeg.stream_command(@song.file_path, @bitrate), "rb") do |ffmpeg|
      while (chunk = ffmpeg.read(CHUNK_SIZE))
        io.write("#{chunk.bytesize.to_s(16)}\r\n#{chunk}\r\n")
      end
    end

    io.write("0\r\n\r\n")
  end

  def write_unsatisfiable(io, size)
    io.write(
      "HTTP/1.1 416 #{STATUS_TEXT[416]}\r\n" \
      "Content-Range: bytes */#{size}\r\n" \
      "Content-Length: 0\r\n" \
      "Connection: close\r\n\r\n"
    )
  end

  def write_headers(io, status:, length:, content_range: nil)
    lines = [
      "HTTP/1.1 #{status} #{STATUS_TEXT[status]}",
      "Content-Type: #{Transcoder::CONTENT_TYPE}",
      "Content-Length: #{length}",
      "Accept-Ranges: bytes"
    ]
    lines << "Content-Range: #{content_range}" if content_range
    lines << "Connection: close"

    io.write("#{lines.join("\r\n")}\r\n\r\n")
  end
end
