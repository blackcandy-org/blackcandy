# frozen_string_literal: true

class SettingsController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    raise BlackCandy::Error::Forbidden unless is_admin?
    setting = Setting.instance

    if setting.update(setting_params)
      MediaSyncJob.perform_later if setting_params[:media_path]
      flash.now[:success] = t("success.update")
    else
      flash_errors_message(setting, now: true)
    end
  end

  private

  def setting_params
    params.require(:setting).permit(Setting::AVAILABLE_SETTINGS)
  end
end
