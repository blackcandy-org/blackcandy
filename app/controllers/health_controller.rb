# frozen_string_literal: true

class HealthController < ActionController::Base
  rescue_from(Exception) { head :internal_server_error }

  def show
    head :ok
  end
end
