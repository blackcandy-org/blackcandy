# frozen_string_literal: true

class Dialog::ArtistsController < DialogController
  before_action :require_admin

  def edit
    @artist = Artist.find(params[:id])
  end
end
