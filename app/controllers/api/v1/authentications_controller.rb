# frozen_string_literal: true

module Api
  module V1
    class AuthenticationsController < ApiController
      skip_before_action :find_current_user
      skip_before_action :require_login

      def create
        session = UserSession.new(session_params.merge({remember_me: true}).to_h)

        if params[:with_session]
          raise BlackCandy::InvalidCredential unless session.save
        else
          raise BlackCandy::InvalidCredential unless session.valid?
        end

        @current_user = User.find_by(email: session_params[:email])

        raise BlackCandy::InvalidCredential unless @current_user.present?

        @current_user.regenerate_api_token if @current_user.api_token.blank?
      end

      private

      def session_params
        params.require(:user_session).permit(:email, :password)
      end
    end
  end
end
