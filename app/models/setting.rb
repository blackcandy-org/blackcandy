# frozen_string_literal: true

class Setting < ApplicationRecord
  include GlobalSettingConcern

  AVAILABLE_BITRATE_OPTIONS = [128, 192, 320].freeze

  has_setting :media_path, default: proc { BlackCandy::Config.media_path }
  has_setting :discogs_token
  has_setting :transcode_bitrate, type: :integer, default: 128
  has_setting :allow_transcode_lossless, type: :boolean, default: false

  validates :transcode_bitrate, inclusion: {in: AVAILABLE_BITRATE_OPTIONS}, allow_nil: true
  validate :media_path_exist

  private

  def media_path_exist
    return if media_path.blank?

    path = File.expand_path(media_path)

    errors.add(:media_path, :not_exist) unless File.exist?(path)
    errors.add(:media_path, :unreadable) unless File.readable?(path)
  end
end
