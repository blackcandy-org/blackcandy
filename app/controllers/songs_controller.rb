# frozen_string_literal: true

class SongsController < ApplicationController
  before_action :require_login

  def index
    @songs = Song.includes(:artist).all
    @playlist = @songs.pluck(:id).to_json
  end

  def show
    @song = Song.find_by(id: params[:id])
  end
end
