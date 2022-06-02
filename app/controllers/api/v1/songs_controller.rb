# frozen_string_literal: true

module Api
  module V1
    class SongsController < ApiController
      def show
        @song = Song.find(params[:id])
        @song_format = need_transcode?(@song.format) ? Stream::TRANSCODE_FORMAT : @song.format
      end
    end
  end
end
