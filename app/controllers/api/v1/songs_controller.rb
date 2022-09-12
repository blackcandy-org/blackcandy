# frozen_string_literal: true

module Api
  module V1
    class SongsController < ApiController
      def show
        @song = Song.find(params[:id])
      end
    end
  end
end
