# frozen_string_literal: true

module Api
  module V1
    class AuthenticationsController < ApiController
      skip_before_action :find_current_session, only: [:create]
      skip_before_action :require_login, only: [:create]

      def create
        @session = Session.build_from_credential(session_params)
        raise BlackCandy::InvalidCredential unless @session.save

        login(@session) if params[:with_cookie]
      end

      def destroy
        Current.session.destroy
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
