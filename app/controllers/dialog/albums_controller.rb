# frozen_string_literal: true

module Dialog
  class AlbumsController < ApplicationController
    before_action :require_admin

    def edit
      @album = Album.find(params[:id])
    end
  end
end
