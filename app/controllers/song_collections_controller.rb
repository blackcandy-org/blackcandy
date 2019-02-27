# frozen_string_literal: true

class SongCollectionsController < ApplicationController
  before_action :require_login

  def index
    @song_collections = Current.user.song_collections.order(id: :desc)
  end

  def create
    @song_collection = Current.user.song_collections.new song_collection_params

    if @song_collection.save
      flash.now[:success] = 'create success'
    else
      flash.now[:error] = 'create fail'
    end
  end

  private

    def song_collection_params
      params.require(:song_collection).permit(:name)
    end
end
