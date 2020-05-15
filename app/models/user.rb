# frozen_string_literal: true

class User < ApplicationRecord
  AVAILABLE_THEME_OPTIONS = %w(dark light auto)
  DEFAULT_THEME = 'dark'

  include ScopedSetting

  before_create :downcase_email
  after_create :create_buildin_playlists

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, length: { minimum: 6 }

  has_many :playlists, -> { where(type: nil) }, dependent: :destroy
  has_one :current_playlist, dependent: :destroy
  has_one :favorite_playlist, dependent: :destroy

  has_secure_password

  scoped_field :theme, default: DEFAULT_THEME, available_options: AVAILABLE_THEME_OPTIONS

  def update_settings(settings)
    settings.each do |key, value|
      send("#{key}=", value)
    end
  end

  def all_playlists
    playlists.unscope(where: :type)
  end

  # ensure user always have current playlist
  def current_playlist
    super || create_current_playlist
  end

  # ensure user always have favorite playlist
  def favorite_playlist
    super || create_favorite_playlist
  end

  def favorited?(song)
    favorite_playlist.songs.exists? song.id
  end

  private

    def create_buildin_playlists
      create_current_playlist
      create_favorite_playlist
    end

    def downcase_email
      self.email = email.downcase
    end
end
