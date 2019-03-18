# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :find_current_user

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
    end
  end

  rescue_from Error::Forbidden do |exception|
    respond_to do |format|
      format.js { head :forbidden }
      format.json { head :forbidden }
    end
  end

  private

    def find_current_user
      Current.user = User.find_by(id: session[:user_id])
    end

    def require_login
      redirect_to new_session_path unless logged_in?
    end

    def require_admin
      raise BlackCandy::ForbiddenError unless is_admin?
    end
end
