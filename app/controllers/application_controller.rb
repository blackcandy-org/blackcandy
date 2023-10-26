# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper

  helper_method :turbo_native?, :need_transcode?, :render_flash

  before_action :find_current_user
  before_action :require_login

  rescue_from BlackCandy::Forbidden do |error|
    respond_to do |format|
      format.json { render_json_error(error, :forbidden) }
      format.html { render template: "errors/forbidden", layout: "plain", status: :forbidden }
    end
  end

  rescue_from BlackCandy::InvalidCredential do |error|
    respond_to do |format|
      format.json { render_json_error(error, :unauthorized) }
      format.html { redirect_to new_session_path }
    end
  end

  rescue_from BlackCandy::DuplicatePlaylistSong do |error|
    respond_to do |format|
      format.json { render_json_error(error, :bad_request) }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    respond_to do |format|
      format.json { render_json_error(OpenStruct.new(type: "RecordNotFound", message: error.message), :not_found) }
      format.html { render template: "errors/not_found", layout: "plain", status: :not_found }
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    logout_current_user
  end

  def need_transcode?(song)
    song_format = song.format

    return true unless song_format.in?(Stream::SUPPORTED_FORMATS)
    return true if browser.safari? && !song_format.in?(Stream::SAFARI_SUPPORTED_FORMATS)
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
    raise BlackCandy::Forbidden if BlackCandy::Config.demo_mode? || !is_admin?
  end

  def logout_current_user
    UserSession.find&.destroy
    cookies.delete(:user_id)

    redirect_to new_session_path
  end

  def turbo_ios?
    request.user_agent.to_s.match?(/Turbo Native iOS/)
  end

  def turbo_android?
    request.user_agent.to_s.match?(/Turbo Native Android/)
  end

  def render_json_error(error, status)
    render json: {type: error.type, message: error.message}, status: status
  end

  def send_local_file(file_path, format, nginx_headers: {})
    if BlackCandy::Config.nginx_sendfile?
      nginx_headers.each { |name, value| response.headers[name] = value }
      send_file file_path

      return
    end

    # Use Rack::File to support HTTP range without nginx. see https://github.com/rails/rails/issues/32193
    Rack::File.new(nil).serving(request, file_path).tap do |(status, headers, body)|
      self.status = status
      self.response_body = body

      headers.each { |name, value| response.headers[name] = value }

      response.headers["Content-Type"] = Mime[format]
      response.headers["Content-Disposition"] = "attachment"
    end
  end
end
