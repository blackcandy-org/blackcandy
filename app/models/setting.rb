# frozen_string_literal: true

class Setting < ApplicationRecord
  include GlobalSetting

  AVAILABLE_BITRATE_OPTIONS = [128, 192, 320].freeze

  has_settings :media_path, :discogs_token
  has_setting :transcode_bitrate, type: :integer, default: 128, available_options: AVAILABLE_BITRATE_OPTIONS
  has_setting :allow_transcode_lossless, type: :boolean, default: false
end
