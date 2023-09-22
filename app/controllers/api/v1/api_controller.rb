# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      rescue_from ActiveRecord::RecordNotUnique do
        render json: ApiError.new(:record_not_unique, t("error.already_in_playlist")), status: :bad_request
      end

      private

      # If user already has logged in then authenticate with current session,
      # otherwise authenticate with api token.
      def find_current_user
        Current.user = UserSession.find&.user

        return if logged_in?

        authenticate_with_http_token do |token, options|
          user = User.find_by(api_token: token)
          return unless user.present?

          # Compare the tokens in a time-constant manner, to mitigate timing attacks.
          Current.user = user if ActiveSupport::SecurityUtils.secure_compare(user.api_token, token)
        end
      end

      def require_login
        head :unauthorized unless logged_in?
      end
    end
  end
end
