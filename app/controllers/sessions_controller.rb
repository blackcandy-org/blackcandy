# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :find_user, only: [:create]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    if @user&.authenticate(params[:session][:password])
      session[:user_id] = @user.id
    else
      flash[:error] = t('error.login')
    end

    redirect_to root_path
  end

  def destroy
    return unless logged_in?

    session.delete(:user_id)
    redirect_to new_session_path
  end

  private

    def find_user
      @user = User.find_by(email: params[:session][:email].downcase)
    end
end
