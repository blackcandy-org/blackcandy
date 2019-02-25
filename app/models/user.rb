# frozen_string_literal: true

class User < ApplicationRecord
  include Playlistable

  before_create :downcase_email

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 },
    unless: Proc.new { |user| user.password.blank? }

  has_many :song_collections, dependent: :destroy
  has_secure_password
  has_playlists :current, :favorite

  private

    def downcase_email
      self.email = email.downcase
    end
end
