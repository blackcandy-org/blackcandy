# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def show
  end

  def update
    Setting.update(setting_params)

    if setting_params[:media_path]
      begin
        Media.sync
      rescue BlackCandyError::InvalidFilePath => error
        flash.now[:error] = error.message; return
      end
    end

    flash.now[:success] = t('success.update')
  end

  private

    def setting_params
      params.require(:setting).permit(Setting::AVAILABLE_SETTINGS)
    end
end
