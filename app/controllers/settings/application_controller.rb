# frozen_string_literal: true

class Settings::ApplicationController < ApplicationController
  layout "settings"
  before_action :require_admin
end
