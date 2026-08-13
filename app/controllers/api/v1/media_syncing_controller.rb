# frozen_string_literal: true

module Api
  module V1
    class MediaSyncingController < ApiController
      before_action :require_admin

      def create
        if Media.syncing?
          render json: { syncing: true, message: I18n.t("error.syncing_in_progress") }, status: :conflict
        else
          MediaSyncAllJob.perform_later
          render json: { syncing: true, message: I18n.t("notice.sync_completed") }, status: :accepted
        end
      end
    end
  end
end
