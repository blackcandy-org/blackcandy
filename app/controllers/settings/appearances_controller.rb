# frozen_string_literal: true

class Settings::AppearancesController < ApplicationController
  layout "settings"

  def show
    @user = Current.user
  end
end
