# frozen_string_literal: true

class MediaSyncJob < ApplicationJob
  include BlackCandy::Configurable

  has_config :parallel_processor_count, default: Parallel.processor_count, env_prefix: "media_sync"

  queue_as :critical

  # Limits the concurrency to 1 to prevent inconsistent media syncing data.
  limits_concurrency to: 1, key: :media_sync

  before_perform :before_sync

  after_perform do |job|
    sync_type = job.arguments.first
    after_sync(fetch_external_metadata: sync_type != :removed)
  end

  def perform(type, file_paths = [])
    parallel_sync(type, file_paths)
  end

  def self.parallel_processor_count
    return 0 unless Setting.enable_parallel_media_sync?
    config.parallel_processor_count
  end

  private

  def parallel_sync(type, file_paths)
    parallel_processor_count = self.class.parallel_processor_count
    grouped_file_paths = (parallel_processor_count > 0) ? file_paths.in_groups(parallel_processor_count, false).compact_blank : [file_paths]

    Parallel.each grouped_file_paths, in_processes: parallel_processor_count do |paths|
      Media.sync(type, paths)
    end
  end

  def before_sync
    Media.syncing = true
  end

  def after_sync(fetch_external_metadata: true)
    Media.syncing = false
    Media.fetch_external_metadata if fetch_external_metadata
  end
end
