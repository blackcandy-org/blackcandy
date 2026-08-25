# frozen_string_literal: true

class Songs::LyricsController < ApplicationController
  layout "lyrics"

  def show
    @song = Song.find(params[:song_id])
  end
end
