# frozen_string_literal: true

class SettingsController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    raise BlackCandyError::Forbidden unless is_admin?

    Setting.update(setting_params)

    if setting_params[:media_path]
      begin
        Media.sync
      rescue BlackCandyError::InvalidFilePath => e
        flash.now[:error] = e.message
        return
      end
    end

    flash.now[:success] = t("success.update")
  end

  private

  def setting_params
    params.require(:setting).permit(Setting::AVAILABLE_SETTINGS)
  end
end
