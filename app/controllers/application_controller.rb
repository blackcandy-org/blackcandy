# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :find_current_user
  before_action :require_login

  rescue_from BlackCandyError::NotFound do
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
      format.html { render template: "errors/not_found", layout: "plain", status: :not_found }
    end
  end

  rescue_from BlackCandyError::Forbidden do
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
      format.html { render template: "errors/forbidden", layout: "plain", status: :forbidden }
    end
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
  end

  def require_login
    redirect_to new_session_path unless logged_in?
  end

  def require_admin
    raise BlackCandyError::Forbidden unless is_admin?
  end
end
