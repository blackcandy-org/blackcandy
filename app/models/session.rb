class Session < ApplicationRecord
  before_create :find_current_info
  belongs_to :user

  def self.build_from_credential(credential)
    user = User.find_by(email: credential[:email])

    # User authentication has been migrated from Authlogic to has_secure_password, so for backward compatibility
    # we need to check password with deprecated_password_salt. After user login successfully, we will
    # update password_digest and remove deprecated_password_salt in the callback.
    authed_user = User.authenticate_by(email: user&.email, password: "#{credential[:password]}#{user&.deprecated_password_salt}")
    authed_user&.update(password: credential[:password]) if authed_user&.deprecated_password_salt.present?

    new(user: authed_user)
  end

  private

  def find_current_info
    self.ip_address = Current.ip_address
    self.user_agent = Current.user_agent
  end
end
