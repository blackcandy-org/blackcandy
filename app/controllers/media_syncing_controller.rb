# frozen_string_literal: true

class MediaSyncingController < ApplicationController
  layout false

  before_action :require_admin

  def show
  end

  def create
    if Media.syncing?
      flash[:alert] = t("error.syncing_in_progress")
      redirect_to setting_library_path
    else
      Media.syncing = true
      MediaSyncAllJob.perform_later(full: params[:full].present?)
    end
  end
end
