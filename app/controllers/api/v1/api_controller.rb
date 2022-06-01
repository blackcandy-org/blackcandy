# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      private

      def find_current_user
        Current.user = UserSession.find&.user

        return if logged_in?

        Current.user = authenticate_with_http_token do |token, options|
          user = User.find_by(api_token: token)

          return unless user.present?
          return user if ActiveSupport::SecurityUtils.secure_compare(user.api_token, token)
        end
      end

      def require_login
        head :unauthorized unless logged_in?
      end
    end
  end
end
