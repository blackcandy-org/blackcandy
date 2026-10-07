# frozen_string_literal: true

module My
  class RecentlyPlayedController < ApplicationController
    def index
      @albums = Current.user.recently_played_albums.with_attached_cover_image
    end
  end
end
