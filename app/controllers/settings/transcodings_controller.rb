# frozen_string_literal: true

class Settings::TranscodingsController < Settings::ApplicationController
  def show
  end

  def update
    Setting.instance.update!(setting_params)

    redirect_to settings_transcoding_path, notice: t("notice.updated")
  end

  private

  def setting_params
    params.require(:setting).permit(:allow_transcode_lossless, :transcode_bitrate)
  end
end
