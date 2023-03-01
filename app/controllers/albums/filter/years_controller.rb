# frozen_string_literal: true

class Albums::Filter::YearsController < ApplicationController
  def index
    @years = Album.distinct.order(:year).pluck(:year).compact
  end
end
