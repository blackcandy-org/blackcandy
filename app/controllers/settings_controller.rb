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
        validate_media_path
        MediaSyncJob.perform_later
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

  def validate_media_path
    media_path = File.expand_path(setting_params[:media_path])

    raise BlackCandyError::InvalidFilePath, I18n.t("error.media_path_blank") unless File.exist?(media_path)
    raise BlackCandyError::InvalidFilePath, I18n.t("error.media_path_unreadable") unless File.readable?(media_path)
  end
end
