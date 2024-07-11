# frozen_string_literal: true

class Setting < ApplicationRecord
  include GlobalSettingConcern

  AVAILABLE_BITRATE_OPTIONS = [128, 192, 320].freeze

  has_setting :media_path, default: proc { BlackCandy.config.media_path }
  has_setting :discogs_token
  has_setting :transcode_bitrate, type: :integer, default: 128
  has_setting :allow_transcode_lossless, type: :boolean, default: false
  has_setting :enable_media_listener, type: :boolean, default: false
  has_setting :enable_parallel_media_sync, type: :boolean, default: false

  validates :transcode_bitrate, inclusion: {in: AVAILABLE_BITRATE_OPTIONS}, allow_nil: true
  validate :media_path_exist
  validate :parallel_media_sync_database

  after_update :toggle_media_listener, if: :saved_change_to_enable_media_listener?
  after_update_commit :sync_media, if: :saved_change_to_media_path?

  private

  def media_path_exist
    return if media_path.nil?

    errors.add(:media_path, :blank) and return if media_path.blank?

    path = File.expand_path(media_path)

    errors.add(:media_path, :not_exist) unless File.exist?(path)
    errors.add(:media_path, :unreadable) unless File.readable?(path)
  end

  def parallel_media_sync_database
    return unless enable_parallel_media_sync?

    if BlackCandy.config.db_adapter == "sqlite"
      errors.add(:enable_parallel_media_sync, :not_supported_with_sqlite)
    end
  end

  def sync_media
    MediaSyncJob.perform_later
  end

  def toggle_media_listener
    if enable_media_listener?
      MediaListener.start
    else
      MediaListener.stop
    end
  end
end
