# frozen_string_literal: true

class SettingsController < ApplicationController
  def show
  end

  def update
    if params[:user_id].present?
      update_user_settings
    else
      update_global_settings
    end

    flash.now[:success] = t('success.update')
  end

  private

    def update_global_settings
      raise BlackCandyError::Forbidden unless is_admin?

      Setting.update(setting_params)

      if setting_params[:media_path]
        begin
          Media.sync
        rescue BlackCandyError::InvalidFilePath => error
          flash.now[:error] = error.message; return
        end
      end
    end

    def update_user_settings
      user = User.find(params[:user_id])
      raise BlackCandyError::Forbidden unless user == Current.user

      user.update_settings(user_setting_params)
    end

    def setting_params
      params.require(:setting).permit(Setting::AVAILABLE_SETTINGS)
    end

    def user_setting_params
      params.require(:setting).permit(User::AVAILABLE_SETTINGS)
    end
end
