# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      private

      def find_current_session
        authenticate_with_http_token do |token, _|
          Current.session = Session.find_signed(token)
        end
      end

      def require_login
        head :unauthorized unless logged_in?
      end
    end
  end
end
