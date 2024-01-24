class MediaSyncJob < ApplicationJob
  queue_as :critical

  def perform(type = :all, file_paths = [])
    return if Media.syncing?

    if type == :all
      Media.sync_all
    else
      Media.sync(type, file_paths)
    end
  end
end
