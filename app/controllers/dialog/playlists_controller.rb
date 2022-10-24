# frozen_string_literal: true

class Dialog::PlaylistsController < ApplicationController
  layout proc { "dialog" unless turbo_native? }

  def index
    @pagy, @playlists = pagy(Current.user.all_playlists.order(created_at: :desc))
  end
end
