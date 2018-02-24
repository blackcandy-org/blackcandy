class User < ApplicationRecord
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_create :downcase_email

  validates :email, presence: true, format: { with: VALID_EMAIL }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  has_secure_password

  private

  def downcase_email
    self.email = email.downcase
  end
end
