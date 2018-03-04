class User < ApplicationRecord
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_create :downcase_email

  validates :email, presence: true, format: { with: VALID_EMAIL }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_secure_password
  has_many :songs, dependent: :destroy

  private

  def downcase_email
    self.email = email.downcase
  end
end
