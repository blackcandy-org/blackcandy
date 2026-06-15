# frozen_string_literal: true

class MediaSyncingController < ApplicationController
  before_action :require_admin

  def create
    if Media.syncing?
      flash[:alert] = t("error.syncing_in_progress")
      redirect_to settings_library_path
    else
      MediaSyncAllJob.perform_later
    end
  end
end
