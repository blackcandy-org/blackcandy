# frozen_string_literal: true

module SessionsHelper
  def logged_in?
    Current.user.present?
  end

  def is_admin?
    Current.user.is_admin
  end
end
