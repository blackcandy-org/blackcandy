# frozen_string_literal: true

# One ffmpeg run writing into the cache, and the write head that readers chase.
#
# The head is the point the encoder has reached in the part file. Readers
# behind it read from disk immediately; readers just ahead of it wait for it;
# readers far ahead are better served by a second encoder started at an offset,
# which is Response's decision rather than this class's.
class Transcoder::Encode
  CHUNK_SIZE = 64 * 1024
  WAIT_SLICE = 0.05

  attr_reader :declared_size, :part_path, :final_path

  def initialize(source:, bitrate:, duration:, part_path:, final_path:)
    @source = source
    @bitrate = bitrate
    @part_path = part_path
    @final_path = final_path
    @declared_size = Transcoder::ByteRange.declared_size(duration, bitrate)

    @mutex = Mutex.new
    @condition = ConditionVariable.new
    @head = 0
    @state = :pending
  end

  def start!
    @mutex.synchronize do
      return self unless @state == :pending

      @state = :running
      @started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    # Created here rather than on the encode thread so that a reader handed
    # this object can always open the part file, even at zero bytes.
    FileUtils.mkdir_p(File.dirname(@part_path))
    @file = File.open(@part_path, "wb")

    @thread = Thread.new { run }
    self
  rescue => error
    discard(error)
    self
  end

  def head
    @mutex.synchronize { @head }
  end

  def finished?
    @mutex.synchronize { @state == :finished }
  end

  def failed?
    @mutex.synchronize { @state == :failed }
  end

  def settled?
    @mutex.synchronize { [ :finished, :failed ].include?(@state) }
  end

  # Observed bytes per second, which is what the wait-or-restart decision in
  # Response compares against the cost of starting a second encoder.
  def rate
    @mutex.synchronize do
      return 0.0 if @started_at.nil? || @head.zero?

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at
      elapsed.positive? ? @head / elapsed : 0.0
    end
  end

  # Blocks until the head passes offset, the encode settles, or timeout.
  def wait_for(offset, timeout:)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

    @mutex.synchronize do
      while @head <= offset && @state == :running
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        break if remaining <= 0

        @condition.wait(@mutex, [ remaining, WAIT_SLICE ].min)
      end

      @head
    end
  end

  private

  def run
    Transcoder.encode_semaphore.acquire

    begin
      IO.popen(Transcoder::Ffmpeg.stream_command(@source, @bitrate), "rb") do |ffmpeg|
        while (chunk = ffmpeg.read(CHUNK_SIZE))
          @file.write(chunk)
          @file.flush
          advance(chunk.bytesize)
        end
      end

      raise "ffmpeg exited #{$?.exitstatus}" unless $?.success?

      settle_length(@file)
      @file.fsync
    ensure
      @file.close unless @file.closed?
    end

    publish
  rescue => error
    discard(error)
  ensure
    Transcoder.encode_semaphore.release
  end

  # The declared length carries a margin over the prediction, so the normal
  # case is padding the tail with silence to land on it exactly.
  def settle_length(file)
    written = head

    if written > @declared_size
      # Only reachable if the duration probe was wrong. An honest
      # Content-Length matters more than the last fraction of a second.
      Rails.logger.warn("Transcoder: output exceeded declared size by #{written - @declared_size} bytes")
      file.truncate(@declared_size)
      file.flush
      @mutex.synchronize { @head = @declared_size }
    elsif written < @declared_size
      padding = Transcoder::Ffmpeg.padding(@declared_size - written, @bitrate)
      file.write(padding)
      # Readers chase the head, so the bytes have to reach the filesystem
      # before the head is allowed to point past them.
      file.flush
      advance(padding.bytesize)
    end
  end

  # A file at the final path is complete by construction, which is what makes
  # existence a sufficient validity check.
  def publish
    File.rename(@part_path, @final_path)

    @mutex.synchronize do
      @state = :finished
      @condition.broadcast
    end

    Transcoder::Cache.sweep_later
  end

  def discard(error)
    Rails.logger.error("Transcoder encode failed: #{error.class}: #{error.message}")
    @file.close if @file && !@file.closed?
    FileUtils.rm_f(@part_path)

    @mutex.synchronize do
      @state = :failed
      @condition.broadcast
    end
  end

  def advance(bytes)
    @mutex.synchronize do
      @head += bytes
      @condition.broadcast
    end
  end
end
