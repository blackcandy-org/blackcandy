class MediaSyncJob < ApplicationJob
  queue_as :default
  before_enqueue :start_syncing
  after_perform :stop_syncing

  def perform
    Media.sync
  end

  private

  def start_syncing
    Media.syncing = true
  end

  def stop_syncing
    Media.syncing = false
  end
end
