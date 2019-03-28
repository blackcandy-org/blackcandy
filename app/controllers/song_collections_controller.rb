# frozen_string_literal: true

class SongCollectionsController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_song_collction, only: [:show, :destroy, :update]

  def index
    @pagy, @song_collections = pagy_countless(Current.user.song_collections.order(created_at: :desc))
  end

  def show
    @playlist = @song_collection.playlist
    @pagy, @songs = pagy_countless(@playlist.songs)
  end

  def create
    @song_collection = Current.user.song_collections.new song_collection_params

    if @song_collection.save
      flash.now[:success] = t('success.create')
    else
      flash.now[:error] = @song_collection.errors.full_messages.join(' ')
    end
  end

  def update
    @song_collection.update(song_collection_params)
  end

  def destroy
    @song_collection.destroy
    @pagy, @song_collections = pagy_countless(Current.user.song_collections.order(created_at: :desc))

    render 'index'
  end

  private

    def song_collection_params
      params.require(:song_collection).permit(:name)
    end

    def find_song_collction
      @song_collection = Current.user.song_collections.find(params[:id])
    end
end
