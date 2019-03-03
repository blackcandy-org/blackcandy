# frozen_string_literal: true

class SongCollectionsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def index
    @pagy, @song_collections = pagy_countless(Current.user.song_collections.order(id: :desc))
  end

  def show
    @song_collection = SongCollection.find_by(id: params[:id])
    @pagy, @songs = pagy_countless(@song_collection.playlist.songs)
  end

  def create
    @song_collection = Current.user.song_collections.new song_collection_params

    if @song_collection.save
      flash.now[:success] = t('text.create_success')
    else
      flash.now[:error] = @song_collection.errors.full_messages.join(' ')
    end
  end

  private

    def song_collection_params
      params.require(:song_collection).permit(:name)
    end
end
