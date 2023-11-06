# frozen_string_literal: true

class User < ApplicationRecord
  AVAILABLE_THEME_OPTIONS = %w[dark light auto].freeze
  DEFAULT_THEME = "auto"
  RECENTLY_PLAYED_LIMIT = 10

  include ScopedSettingConcern

  has_secure_password
  has_setting :theme, default: DEFAULT_THEME
  serialize :recently_played_album_ids, type: Array, coder: YAML

  before_create :downcase_email
  before_update :remove_deprecated_password_salt, if: :will_save_change_to_password_digest?
  after_create :create_buildin_playlists

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}, uniqueness: {case_sensitive: false}
  validates :password, allow_nil: true, length: {minimum: 6}
  validates :theme, inclusion: {in: AVAILABLE_THEME_OPTIONS}, allow_nil: true

  has_many :playlists, -> { where(type: nil) }, inverse_of: :user, dependent: :destroy
  has_many :sessions, dependent: :destroy

  has_one :current_playlist, dependent: :destroy
  has_one :favorite_playlist, dependent: :destroy

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

  # User created playlists with favorite playlist
  def all_playlists
    playlists.unscope(where: :type).where("playlists.type IS NULL OR playlists.type = ?", "FavoritePlaylist")
  end

  def recently_played_albums
    album_ids = recently_played_album_ids
    order_clause = album_ids.map { |id| "id=#{id} desc" }.join(",")

    Album.includes(:artist).where(id: album_ids).order(Arel.sql(order_clause))
  end

  def add_album_to_recently_played(album)
    album_ids = recently_played_album_ids.unshift(album.id).uniq.take(RECENTLY_PLAYED_LIMIT)
    update_column(:recently_played_album_ids, album_ids)
  end

  private

  def remove_deprecated_password_salt
    self.deprecated_password_salt = nil if deprecated_password_salt.present?
  end

  def create_buildin_playlists
    create_current_playlist
    create_favorite_playlist
  end

  def downcase_email
    self.email = email.downcase
  end
end
