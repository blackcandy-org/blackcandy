# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  def require_login
    redirect_to new_session_path unless logged_in?
  end

  def require_admin
    head :forbidden unless is_admin?
  end
end
