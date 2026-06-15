# frozen_string_literal: true

class Settings::AppearancesController < Settings::ApplicationController
  skip_before_action :require_admin

  def show
    @user = Current.user
  end
end
