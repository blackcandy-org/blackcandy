# frozen_string_literal: true

module SessionsHelper
  def logged_in?
    Current.session.present?
  end

  def is_admin?
    Current.user.is_admin
  end

  def login(session)
    cookies.signed[:session_id] = {value: session.id, expires: 1.year.from_now, httponly: true, secure: BlackCandy.config.force_ssl?}
  end

  def logout
    reset_session
    cookies.delete(:session_id)

    redirect_to new_session_path
  end
end
