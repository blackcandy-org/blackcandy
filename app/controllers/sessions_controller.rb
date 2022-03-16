# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "plain"

  skip_before_action :require_login

  def new
    redirect_to root_path if logged_in?
  end

  def create
    session = UserSession.new(session_params.to_h)

    if session.save
      redirect_to root_path
    else
      flash.now[:error] = t("error.login")
    end
  end

  def destroy
    return unless logged_in?

    UserSession.find.destroy
    cookies.delete(:user_id)
    redirect_to new_session_path
  end

  private

  def session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end
end
