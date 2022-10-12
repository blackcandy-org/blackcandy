# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  helper_method :turbo_native?, :need_transcode?

  before_action :find_current_user
  before_action :require_login

  rescue_from BlackCandyError::Forbidden do
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
      format.html { render template: "errors/forbidden", layout: "plain", status: :forbidden }
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    logout_current_user
  end

  def browser
    @browser ||= Browser.new(
      request.headers["User-Agent"],
      accept_language: request.headers["Accept-Language"]
    )
  end

  def is_safari?
    browser.safari? || browser.core_media?
  end

  def need_transcode?(format)
    return true if format.in?(Stream::UNSUPPORTED_FORMATS)
    return true if is_safari? && format.in?(Stream::SAFARI_UNSUPPORTED_FORMATS)
    return true if is_turbo_ios? && format.in?(Stream::IOS_UNSUPPORTED_FORMATS)

    Setting.allow_transcode_lossless ? format.in?(Stream::LOSSLESS_FORMATS) : false
  end

  def flash_errors_message(object, now: false)
    errors_message = object.errors.full_messages.join(". ")

    if now
      flash.now[:error] = errors_message
    else
      flash[:error] = errors_message
    end
  end

  private

  def find_current_user
    Current.user = UserSession.find&.user
    cookies.signed[:user_id] ||= Current.user&.id
  end

  def require_login
    return if logged_in?

    if turbo_native?
      head :unauthorized
    else
      redirect_to new_session_path
    end
  end

  def require_admin
    raise BlackCandyError::Forbidden unless is_admin?
  end

  def logout_current_user
    UserSession.find&.destroy
    cookies.delete(:user_id)

    redirect_to new_session_path
  end

  def is_turbo_ios?
    request.user_agent.to_s.match?(/Turbo Native iOS/)
  end

  def is_turbo_android?
    request.user_agent.to_s.match?(/Turbo Native Android/)
  end

  def turbo_native?
    is_turbo_ios? || is_turbo_android?
  end
end
