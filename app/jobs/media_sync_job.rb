class MediaSyncJob < ApplicationJob
  queue_as :default
  after_perform :sync_completed

  def perform
    Media.is_syncing = true
    Media.sync
  end

  private

  def sync_completed
    Media.is_syncing = false
  end
end
