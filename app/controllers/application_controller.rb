# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :find_current_user
  before_action :require_login

  rescue_from BlackCandyError::NotFound do |exception|
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
      format.html { render template: 'errors/not_found', layout: 'plain', status: :not_found }
    end
  end

  rescue_from BlackCandyError::Forbidden do |exception|
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
      format.html { render template: 'errors/forbidden', layout: 'plain', status: :forbidden }
    end
  end

  def browser
    @browser ||= Browser.new(
      request.headers['User-Agent'],
      accept_language: request.headers['Accept-Language']
    )
  end

  def is_safari?
    browser.safari? || browser.core_media?
  end

  private

    def find_current_user
      Current.user = User.find_by(id: session[:user_id])
    end

    def require_login
      redirect_to new_session_path unless logged_in?
    end

    def require_admin
      raise BlackCandyError::Forbidden unless is_admin?
    end
end
