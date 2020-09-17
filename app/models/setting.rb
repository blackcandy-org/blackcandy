# frozen_string_literal: true

class Setting < ApplicationRecord
  include GlobalSetting

  has_settings :media_path, :discogs_token
end
