# frozen_string_literal: true

class SessionsController < ApplicationController
  layout :sessions_layout

  skip_before_action :require_login, only: [ :new, :create ]
  before_action :require_admin, only: [ :index, :destroy ]
  before_action :find_session, only: [ :destroy ]

  rate_limit to: 10, within: 3.minutes, only: :create

  def index
    @current_session = Current.session
    @sessions = Session.includes(:user).where.not(id: @current_session.id).order(created_at: :desc)
  end

  def new
    redirect_to root_path if logged_in?
  end

  def create
    @session = Session.build_from_credential(session_params)
    raise BlackCandy::InvalidCredential unless @session.save

    login

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render :show, status: :created }
    end
  end

  def destroy
    raise BlackCandy::Forbidden if @session.current?

    @session.destroy

    respond_to do |format|
      format.html { redirect_to sessions_path, notice: t("notice.deleted") }
      format.json { head :no_content }
    end
  end

  private

  def sessions_layout
    (action_name == "index") ? "settings" : "plain"
  end

  def find_session
    @session = Session.find(params[:id])
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def login
    cookies.signed[:session_id] = { value: @session.id, expires: 1.year.from_now, httponly: true, secure: BlackCandy.config.force_ssl? }
  end
end
