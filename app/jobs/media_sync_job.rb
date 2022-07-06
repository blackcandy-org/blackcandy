class MediaSyncJob < ApplicationJob
  queue_as :default
  before_enqueue :start_syncing
  after_perform :stop_syncing

  def perform(type = :all, file_paths = [])
    Media.sync(type, file_paths)
  end

  private

  def start_syncing
    Media.syncing = true
  end

  def stop_syncing
    Media.syncing = false
  end
end
