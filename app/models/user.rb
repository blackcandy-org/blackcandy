# frozen_string_literal: true

class User < ApplicationRecord
  include Redis::Objects

  before_create :downcase_email
  after_destroy :delete_redis_keys

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 },
    unless: Proc.new { |user| user.password.blank? }

  has_many :song_collections, dependent: :destroy
  has_secure_password

  set :current_song_ids
  set :favorite_song_ids

  def current_playlist
    @current_playlist ||= Playlist.new(current_song_ids)
  end

  def favorite_playlist
    @favorite_playlist ||= Playlist.new(favorite_song_ids)
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def delete_redis_keys
      self.class.redis_objects.each do |key, opts|
        redis.del(redis_field_key(key))
      end
    end
end
