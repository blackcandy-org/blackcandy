# frozen_string_literal: true

class SongsController < ApplicationController
  render_in_dialog :edit

  before_action :require_admin, only: [ :edit, :update ]
  before_action :find_song, except: [ :index ]
  before_action :get_sort_option, only: [ :index ]

  def index
    records = Song.includes(:artist, :album)
      .filter_records(filter_params)
      .sort_records(*sort_params)

    @pagy, @songs = pagy(records)
  end

  def show
  end

  def edit
  end

  def update
    @song.update!(song_params)

    respond_to do |format|
      format.html { redirect_back_or_to songs_path, notice: t("notice.updated") }
      format.json { render :show }
    end
  end

  private

  def song_params
    params.require(:song).permit(:lyrics)
  end

  def find_song
    @song = Song.find(params[:id])
  end

  def filter_params
    params[:filter]&.slice(*Song::VALID_FILTERS)
  end

  def sort_params
    [ params[:sort], params[:sort_direction] ]
  end

  def get_sort_option
    @sort_option = Song::SORT_OPTION
  end
end
