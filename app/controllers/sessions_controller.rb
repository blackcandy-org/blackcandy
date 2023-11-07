# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "plain"

  skip_before_action :require_login
  before_action :find_session, only: [:destroy]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    session = Session.build_from_credential(session_params)

    if session.save
      login(session)
      redirect_to root_path
    else
      flash.now[:error] = t("error.login")
    end
  end

  def destroy
    return unless logged_in?

    @session.destroy
    logout
  end

  private

  def find_session
    @session = Current.user.sessions.find(params[:id])
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
