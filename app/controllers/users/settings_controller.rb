# frozen_string_literal: true

class Users::SettingsController < ApplicationController
  before_action :find_user
  before_action :auth_user

  def update
    return unless @user.update(user_setting_params)
    flash.now[:success] = t("notice.updated")
  end

  private

  def user_setting_params
    params.require(:user).permit(User::AVAILABLE_SETTINGS)
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def auth_user
    raise BlackCandy::Forbidden unless @user == Current.user
  end
end
