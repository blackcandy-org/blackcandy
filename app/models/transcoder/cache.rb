# frozen_string_literal: true

# Cache keys, single-flight, atomic publication, and a size-capped LRU sweep.
class Transcoder::Cache
  STALE_PART_AGE = 6.hours

  @registry = {}
  @registry_mutex = Mutex.new
  @sweeping = false

  class << self
    def root
      Pathname.new(Transcoder.config.cache_path)
    end

    # Keyed on md5_hash rather than song_id, so the entry survives a re-scan
    # that changes the row id and self-invalidates when the file changes.
    def key(song, bitrate)
      Digest::SHA256.hexdigest("#{song.md5_hash}#{bitrate}#{Transcoder::FORMAT}")
    end

    def path(key)
      root.join(key[0, 2], "#{key}.#{Transcoder::FORMAT}")
    end

    # One part file per process. Two Puma workers encoding the same cold track
    # write to different files and both rename onto the same final path, which
    # is atomic either way, so neither can observe the other's partial bytes.
    def part_path(key)
      root.join(key[0, 2], "#{key}.#{Process.pid}.part")
    end

    def complete?(key)
      File.exist?(path(key))
    end

    # Recorded explicitly rather than relying on atime, which many filesystems
    # are mounted not to update.
    def touch(key)
      # File.utime wants a Time, not an ActiveSupport::TimeWithZone.
      File.utime(Time.now, File.mtime(path(key)), path(key))
    rescue Errno::ENOENT
      nil
    end

    # N concurrent callers for the same cold key get one encode and N readers
    # of one part file.
    def encode_for(song:, bitrate:, duration:)
      cache_key = key(song, bitrate)

      @registry_mutex.synchronize do
        @registry.delete_if { |_, encode| encode.settled? }

        @registry[cache_key] ||= Transcoder::Encode.new(
          source: song.file_path,
          bitrate: bitrate,
          duration: duration,
          part_path: part_path(cache_key),
          final_path: path(cache_key)
        ).start!
      end
    end

    def sweep_later
      Thread.new do
        Thread.current.name = "transcoder-sweep"
        sweep
      end
    end

    def sweep
      return unless claim_sweep

      begin
        remove_stale_parts
        evict_over_limit
      ensure
        # Only released by the caller that claimed it, so a sweep that bailed
        # out cannot clear the flag for the one that is still running.
        @registry_mutex.synchronize { @sweeping = false }
      end
    end

    def clear
      FileUtils.rm_rf(root)
      @registry_mutex.synchronize { @registry.clear }
    end

    private

    def claim_sweep
      @registry_mutex.synchronize do
        return false if @sweeping

        @sweeping = true
      end
    end

    # A part file with no live encoder behind it is debris from a crash.
    def remove_stale_parts
      Dir.glob(root.join("*", "*.part")).each do |part|
        FileUtils.rm_f(part) if File.mtime(part) < STALE_PART_AGE.ago
      rescue Errno::ENOENT
        nil
      end
    end

    def evict_over_limit
      limit = Transcoder.config.cache_size.megabytes
      entries = cache_entries
      total = entries.sum { |entry| entry[:size] }

      entries.sort_by! { |entry| entry[:used_at] }

      entries.each do |entry|
        break if total <= limit

        FileUtils.rm_f(entry[:path])
        total -= entry[:size]
      end
    end

    def cache_entries
      Dir.glob(root.join("*", "*.#{Transcoder::FORMAT}")).filter_map do |file|
        stat = File.stat(file)
        { path: file, size: stat.size, used_at: [ stat.atime, stat.mtime ].max }
      rescue Errno::ENOENT
        nil
      end
    end
  end
end
