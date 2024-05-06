class MediaSyncJob < ApplicationJob
  queue_as :critical

  # Limits the concurrency to 1 to prevent inconsistent media syncing data.
  limits_concurrency to: 1, key: :media_sync

  def perform(type = :all, file_paths = [])
    if type == :all
      Media.sync_all
    else
      Media.sync(type, file_paths)
    end
  end
end
