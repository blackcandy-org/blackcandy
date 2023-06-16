# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper

  helper_method :turbo_native?, :need_transcode?, :render_flash

  before_action :find_current_user
  before_action :require_login

  rescue_from BlackCandy::Error::Forbidden do
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
      format.html { render template: "errors/forbidden", layout: "plain", status: :forbidden }
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    logout_current_user
  end

  def need_transcode?(song)
    song_format = song.format

    return true unless song_format.in?(Stream::SUPPORTED_FORMATS)
    return true if safari? && !song_format.in?(Stream::SAFARI_SUPPORTED_FORMATS)
    return true if turbo_ios? && !song_format.in?(Stream::IOS_SUPPORTED_FORMATS)

    Setting.allow_transcode_lossless ? song.lossless? : false
  end

  def flash_errors_message(object, now: false)
    errors_message = object.errors.full_messages.join(". ")

    if now
      flash.now[:error] = errors_message
    else
      flash[:error] = errors_message
    end
  end

  def turbo_native?
    turbo_ios? || turbo_android?
  end

  def redirect_back_with_referer_params(fallback_location:)
    if params[:referer_url].present?
      redirect_to params[:referer_url]
    else
      redirect_back_or_to(fallback_location)
    end
  end

  def render_flash(type: :success, message: "")
    flash[type] = message unless message.blank?
    turbo_stream.update "turbo-flash", partial: "shared/flash"
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
    raise BlackCandy::Error::Forbidden if BlackCandy::Config.demo_mode? || !is_admin?
  end

  def logout_current_user
    UserSession.find&.destroy
    cookies.delete(:user_id)

    redirect_to new_session_path
  end

  def browser
    @browser ||= Browser.new(
      request.headers["User-Agent"],
      accept_language: request.headers["Accept-Language"]
    )
  end

  def safari?
    browser.safari? || browser.core_media?
  end

  def turbo_ios?
    request.user_agent.to_s.match?(/Turbo Native iOS/)
  end

  def turbo_android?
    request.user_agent.to_s.match?(/Turbo Native Android/)
  end
end
