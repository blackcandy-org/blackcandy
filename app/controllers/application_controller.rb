# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :find_current_user

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
      format.html { redirect_to not_found_path, status: :not_found }
    end
  end

  rescue_from BlackCandyError::Forbidden do |exception|
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
      format.html { redirect_to forbidden_path, status: :forbidden }
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
