# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin, only: [:index, :create, :new, :destroy]
  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :auth_user, only: [:edit, :update]

  def index
    @users = User.where.not(id: Current.user.id)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = t("notice.created")
      redirect_to users_path
    else
      flash_errors_message(@user, now: true)
    end
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = t("notice.updated")
    else
      flash_errors_message(@user, now: true)
    end
  end

  def destroy
    # Avoid user delete self
    raise BlackCandy::Forbidden if @user == Current.user

    @user.destroy
    flash.now[:success] = t("notice.deleted")
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def auth_user
    raise BlackCandy::Forbidden if BlackCandy.config.demo_mode?
    raise BlackCandy::Forbidden unless @user == Current.user || is_admin?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
