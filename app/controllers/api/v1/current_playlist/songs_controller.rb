# frozen_string_literal: true

module Api
  module V1
    class CurrentPlaylist::SongsController < ApiController
      def show
        @songs = Current.user.current_playlist.songs
      end
    end
  end
end
