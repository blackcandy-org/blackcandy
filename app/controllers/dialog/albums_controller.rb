# frozen_string_literal: true

module Dialog
  class AlbumsController < DialogController
    before_action :require_admin

    def edit
      @album = Album.find(params[:id])
    end
  end
end
