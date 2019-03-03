# frozen_string_literal: true

class PlaylistController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def show
    case params[:id]
    when 'current'
      playlist = Current.user.current_playlist
    when 'favorite'
      playlist = Current.user.favorite_playlist
    else
      playlist = SongCollection.find_by(id: params[:id]).playlist
    end

    @pagy, @songs = pagy_countless(playlist.songs)
  end
end
