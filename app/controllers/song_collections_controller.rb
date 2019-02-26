# frozen_string_literal: true

class SongCollectionsController < ApplicationController
  before_action :require_login

  def index
    @song_collections = Current.user.song_collections
  end
end
