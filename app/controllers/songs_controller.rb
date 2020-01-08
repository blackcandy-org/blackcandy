# frozen_string_literal: true

class SongsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    records = Song.search(params[:query]).includes(:artist, :album).order(:name)
    @pagy, @songs = pagy_countless(records)
  end

  def show
    @song = Song.find(params[:id])
  end
end
