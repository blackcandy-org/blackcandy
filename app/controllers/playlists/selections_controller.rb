# frozen_string_literal: true

module Playlists
  class SelectionsController < ApplicationController
    render_in_dialog

    def index
      @pagy, @playlists = pagy(Current.user.playlists_with_favorite.order(created_at: :desc))

      if partial_request? && @pagy.page > 1
        render partial: "playlists/selections/page", locals: { playlists: @playlists, pagy: @pagy }
      end
    end
  end
end
