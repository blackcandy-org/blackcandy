# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'base'

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:error] = t('error.login')
      render 'new'
    end
  end

  def destroy
    return unless logged_in?

    session.delete(:user_id)
    redirect_to new_session_path
  end
end
