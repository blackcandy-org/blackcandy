# frozen_string_literal: true

class MediaListener
  SUPPORTED_FORMATS = MediaFile::SUPPORTED_FORMATS.map { |format| %r{\.#{format}$} }
  RUNNING_CACHE_KEY = "media_listener_running"

  @mutex = Mutex.new

  class << self
    def start
      @mutex.synchronize do
        return if @listener

        Listen.logger = Rails.logger

        @listener = Listen.to(File.expand_path(Setting.media_path), only: SUPPORTED_FORMATS, latency: 5, wait_for_delay: 10) do |modified, added, removed|
          MediaSyncJob.perform_later(:modified, modified) if modified.present?
          MediaSyncJob.perform_later(:added, added) if added.present?
          MediaSyncJob.perform_later(:removed, removed) if removed.present?
        end

        @listener.start
        Rails.cache.write(RUNNING_CACHE_KEY, true)
      end
    end

    def stop
      @mutex.synchronize do
        @listener&.stop
        @listener = nil
        Rails.cache.delete(RUNNING_CACHE_KEY)
      end
    end

    def running?
      Rails.cache.read(RUNNING_CACHE_KEY).present?
    end
  end
end
