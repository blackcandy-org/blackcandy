class SongsController < ApplicationController
  before_action :require_login

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
