class MediaSyncJob < ApplicationJob
  queue_as :default

  def perform(type = :all, file_paths = [])
    if type == :all
      Media.sync_all
    else
      Media.sync(type, file_paths)
    end
  end
end
