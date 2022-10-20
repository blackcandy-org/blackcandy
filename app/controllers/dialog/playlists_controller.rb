# frozen_string_literal: true

class Dialog::PlaylistsController < PlaylistsController
  layout proc { "dialog" unless turbo_native? }
end
