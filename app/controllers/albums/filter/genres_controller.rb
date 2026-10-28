# frozen_string_literal: true

class Albums::Filter::GenresController < ApplicationController
  layout false

  def index
    @genres = Album.distinct.order(:genre).pluck(:genre).compact
  end
end
