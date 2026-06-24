# frozen_string_literal: true

module Playlists
  class SelectionsController < ApplicationController
    render_in_dialog

    def index
      @pagy, @playlists = pagy(Current.user.playlists_with_favorite.order(created_at: :desc))
    end
  end
end
