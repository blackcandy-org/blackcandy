# frozen_string_literal: true

class User < ApplicationRecord
  AVAILABLE_THEME_OPTIONS = %w(dark light auto)

  include Playlistable
  include ScopedSetting

  before_create :downcase_email

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, length: { minimum: 6 }

  has_many :song_collections, dependent: :destroy
  has_secure_password
  has_playlists :current, :favorite

  scoped_field :theme, default: 'dark', available_options: AVAILABLE_THEME_OPTIONS

  def update_settings(settings)
    settings.each do |key, value|
      send("#{key}=", value)
    end
  end

  private

    def downcase_email
      self.email = email.downcase
    end
end
