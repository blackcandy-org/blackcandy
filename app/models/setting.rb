# frozen_string_literal: true

class Setting < RailsSettings::Base
  include GlobalSetting

  field :media_path, default: ENV['MEDIA_PATH']
  field :discogs_token

  fields_force_to_string :media_path, :discogs_token

  def self.update(values)
    values.each do |key, value|
      next unless key.to_sym.in?(AVAILABLE_SETTINGS)
      send("#{key}=", value) if value != send(key)
    end
  end
end
