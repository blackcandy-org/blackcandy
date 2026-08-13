# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "plain"

  skip_before_action :require_login

  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.json { render json: { type: "Forbidden", message: I18n.t("error.forbidden") }, status: :forbidden }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { type: "NotFound", message: I18n.t("error.not_found") }, status: :not_found }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { type: "UnprocessableEntity", message: I18n.t("error.unprocessable_entity") }, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { type: "InternalServerError", message: I18n.t("error.internal_server_error") }, status: :internal_server_error }
    end
  end
end
