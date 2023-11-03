# frozen_string_literal: true

module Api
  module V1
    class SystemsController < ApiController
      skip_before_action :find_current_session
      skip_before_action :require_login

      def show
      end
    end
  end
end
