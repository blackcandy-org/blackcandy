# frozen_string_literal: true

class Songs::FavoritesController < ApplicationController
  layout false

  before_action :find_song

  def create
    Current.user.favorite_playlist.songs.push(@song) unless Current.user.favorited?(@song)
  end

  def destroy
    Current.user.favorite_playlist.songs.destroy(@song)
  end

  private

  def find_song
    @song = Song.find(params[:song_id])
  end
end
