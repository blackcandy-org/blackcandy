# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'error'

  def forbidden
    render status: :forbidden
  end

  def not_found
    render status: :not_found
  end

  def unprocessable_entity
    render status: :unprocessable_entity
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
