# frozen_string_literal: true

class SongsController < ApplicationController
  before_action :require_login

  def index
    # @songs = Song.includes(:artist).all
    # @playlist = @songs.select(:id).to_json
    # send_file '/Users/aidewoode/test.mp3'
  end

  def new
    @song = Song.new
  end

  def show
    @song = Song.find_by(id: params[:id])
  end

  def create
    song_params[:media].each do |media|
      current_user.songs.create(media: media)
    end
  end

  private

    def song_params
      params.require(:song).permit(media: [])
    end
end
