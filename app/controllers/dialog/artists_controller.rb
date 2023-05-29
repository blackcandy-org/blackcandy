# frozen_string_literal: true

module Dialog
  class ArtistsController < DialogController
    before_action :require_admin

    def edit
      @artist = Artist.find(params[:id])
    end
  end
end
