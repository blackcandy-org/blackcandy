# frozen_string_literal: true

class UsersController < ApplicationController
  layout "settings"

  before_action :require_admin
  before_action :find_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.where.not(id: Current.user.id)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.create!(user_params)

    respond_to do |format|
      format.html { redirect_to users_path, notice: t("notice.created") }
      format.json { render partial: "users/user", locals: { user: @user }, status: :created }
    end
  end

  def update
    @user.update!(user_params)

    respond_to do |format|
      format.html { redirect_to edit_user_path(@user), notice: t("notice.updated") }
      format.json { render partial: "users/user", locals: { user: @user } }
    end
  end

  def destroy
    # Avoid user delete self
    raise BlackCandy::Forbidden if @user == Current.user

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: t("notice.deleted") }
      format.json { head :no_content }
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
