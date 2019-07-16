# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login
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
      flash[:success] = t('success.create')
      redirect_to users_path
    else
      flash.now[:error] = @user.errors.full_messages.join(' ')
    end
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = t('success.update')
    else
      flash.now[:error] = @user.errors.full_messages.join(' ')
    end
  end

  def destroy
    # Avoit user delete self
    raise BlackCandyError::Forbidden if @user == Current.user

    @user.destroy
    flash.now[:success] = t('success.delete')
  end

  private

    def find_user
      @user = User.find(params[:id])
    end

    def auth_user
      raise BlackCandyError::Forbidden unless @user == Current.user || is_admin?
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
