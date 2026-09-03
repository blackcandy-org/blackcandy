# frozen_string_literal: true

require "etc"

# Streams transcoded audio without holding a Puma thread for the download.
#
# The controller takes the socket off Rails with rack.hijack and hands it here;
# everything after that runs on a worker thread. The copy sits in blocking IO,
# which releases the GVL, so a slow listener costs a thread and nothing else.
class Transcoder
  include BlackCandy::Configurable

  FORMAT = "mp3"
  CONTENT_TYPE = "audio/mpeg"

  has_config :cache_size, default: 10240, env_prefix: "transcoder"
  has_config :cache_path, default: -> { Rails.root.join("tmp/cache/transcoder").to_s }, env_prefix: "transcoder"
  has_config :max_concurrency, default: Etc.nprocessors, env_prefix: "transcoder"

  SEMAPHORE_MUTEX = Mutex.new

  class << self
    # Full hijack is a server capability, not a request one. Puma sets it
    # unconditionally; Rack::Test and the integration tests never do.
    def available?(request)
      request.env["rack.hijack"].respond_to?(:call)
    end

    def serve(io, song:, bitrate:, range: nil)
      Thread.new do
        Thread.current.name = "transcoder"
        Response.new(song: song, bitrate: bitrate, range: range).write_to(io)
      rescue => error
        Rails.logger.error("Transcoder failed: #{error.class}: #{error.message}")
      ensure
        begin
          io.close
        rescue IOError, Errno::EBADF, Errno::ENOTCONN
          nil
        end
      end
    end

    # Bounds concurrent ffmpeg processes.
    #
    # Encodes and restarts get separate pools deliberately. An encode writes to
    # the cache at full speed and finishes; a restart writes straight to the
    # listener and is paced by them, so it can hold a permit for as long as
    # somebody leaves a stream open. Sharing one pool lets a handful of stalled
    # listeners block every new encode, including first plays for other people.
    def encode_semaphore
      semaphore_for(:encode)
    end

    def restart_semaphore
      semaphore_for(:restart)
    end

    private

    # Built lazily but under a lock, so two simultaneous first requests cannot
    # end up with a semaphore each and twice the intended bound. Rebuilt when
    # the configured limit changes, which only happens in tests.
    def semaphore_for(kind)
      SEMAPHORE_MUTEX.synchronize do
        limit = config.max_concurrency
        @semaphores ||= {}

        cached_limit, cached_semaphore = @semaphores[kind]
        return cached_semaphore if cached_semaphore && cached_limit == limit

        @semaphores[kind] = [ limit, Concurrent::Semaphore.new(limit) ]
        @semaphores[kind].last
      end
    end
  end
end
