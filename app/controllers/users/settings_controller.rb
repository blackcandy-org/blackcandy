# frozen_string_literal: true

class Users::SettingsController < ApplicationController
  before_action :find_user
  before_action :auth_user

  def update
    return unless @user.update(user_setting_params)

    # set theme cookie to track theme when user didn't login
    cookies.permanent[:theme] = @user.theme

    flash.now[:success] = t("success.update")
  end

  private

  def user_setting_params
    params.require(:user).permit(User::AVAILABLE_SETTINGS)
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def auth_user
    raise BlackCandyError::Forbidden unless @user == Current.user
  end
end
