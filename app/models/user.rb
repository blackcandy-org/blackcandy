# frozen_string_literal: true

class User < ApplicationRecord
  before_create :downcase_email

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 },
    unless: Proc.new { |user| user.password.blank? }

  has_secure_password

  private

    def downcase_email
      self.email = email.downcase
    end
end
