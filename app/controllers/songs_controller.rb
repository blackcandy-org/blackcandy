# frozen_string_literal: true

class SongsController < ApplicationController
  include Pagy::Backend

  def index
    records = Song.includes(:artist, :album).order(:name)
    @pagy, @songs = pagy(records)
  end

  def show
    @song = Song.find(params[:id])
  end
end
