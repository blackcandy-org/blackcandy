# frozen_string_literal: true

class Setting < RailsSettings::Base
  source Rails.root.join('config/app.yml')
end
