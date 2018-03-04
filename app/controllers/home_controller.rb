class HomeController < ApplicationController
  before_action :require_login

  def index
    @songs = Song.all
    @playlist = @songs.select(:id).to_json
  end
end
