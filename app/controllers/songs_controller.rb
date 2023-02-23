# frozen_string_literal: true

class SongsController < ApplicationController
  include Orderable

  order_by :name, "artist.name", "album.name", "album.year", :created_at

  def index
    records = Song.includes(:artist, :album).order(order_condition)
    @pagy, @songs = pagy(records)
  end
end
