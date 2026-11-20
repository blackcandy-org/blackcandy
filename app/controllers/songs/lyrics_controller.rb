# frozen_string_literal: true

class Songs::LyricsController < ApplicationController
  layout false

  def show
    @song = Song.find(params[:song_id])
  end
end
