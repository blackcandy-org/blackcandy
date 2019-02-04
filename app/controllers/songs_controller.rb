# frozen_string_literal: true

class SongsController < ApplicationController
  before_action :require_login

  def index
    @songs = Song.includes(:artist).all
  end

  def show
    @song = Song.find_by(id: params[:id])
  end
end
