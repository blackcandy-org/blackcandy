# frozen_string_literal: true

class Settings::LibrariesController < ApplicationController
  layout "settings"
  before_action :require_admin

  def show
  end

  def update
    Setting.instance.update!(setting_params)

    redirect_to setting_library_path, notice: t("notice.updated")
  end

  private

  def setting_params
    params.require(:setting).permit(:media_path, :enable_media_listener, :enable_parallel_media_sync)
  end
end
