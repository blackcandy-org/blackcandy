class MediaSyncJob < ApplicationJob
  queue_as :default

  def perform(type = :all, file_paths = [])
    Media.sync(type, file_paths)
  end
end
