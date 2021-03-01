# frozen_string_literal: true

class PlaylistsController < ApplicationController
  layout 'sidebar'

  include Pagy::Backend

  before_action :find_playlist, only: [:destroy, :update]

  def index
    @pagy, @playlists = pagy(Current.user.playlists.order(created_at: :desc))
  end

  def create
    @playlist = Current.user.playlists.new playlist_params

    if @playlist.save
      flash.now[:success] = t('success.create')
    else
      flash.now[:error] = @playlist.errors.full_messages.join(' ')
    end
  end

  def update
    @playlist.update(playlist_params)
  end

  def destroy
    @playlist.destroy
    index; render 'index'
  end

  private

    def find_playlist
      @playlist = Current.user.playlists.find(params[:id])
    end

    def playlist_params
      params.require(:playlist).permit(:name)
    end
end
