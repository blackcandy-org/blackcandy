# frozen_string_literal: true

class Setting < RailsSettings::Base
  AVAILABLE_SETTINGS = %w(media_path discogs_token)

  source Rails.root.join('config/app.yml')

  def self.update(values)
    values.each do |key, value|
      next unless AVAILABLE_SETTINGS.include?(key)
      self[key.to_sym] = value if value != self[key.to_sym]
    end
  end
end
