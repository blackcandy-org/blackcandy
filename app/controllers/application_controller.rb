# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :find_current_user

  private

    def find_current_user
      Current.user = User.find_by(id: session[:user_id])
    end

    def require_login
      redirect_to new_session_path unless logged_in?
    end

    def require_admin
      head :forbidden unless is_admin?
    end
end
