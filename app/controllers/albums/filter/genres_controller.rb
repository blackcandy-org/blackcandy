# frozen_string_literal: true

class Albums::Filter::GenresController < ApplicationController
  def index
    @genres = Album.distinct.order(:genre).pluck(:genre).compact
  end
end
