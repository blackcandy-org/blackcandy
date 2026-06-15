# frozen_string_literal: true

class Settings::IntegrationsController < Settings::ApplicationController
  def show
  end

  def update
    Setting.instance.update!(setting_params)

    redirect_to settings_integration_path, notice: t("notice.updated")
  end

  private

  def setting_params
    params.require(:setting).permit(:discogs_token)
  end
end
