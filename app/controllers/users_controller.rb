# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin, only: [:index, :create, :new]
  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :auth_user, only: [:edit, :update]

  def index
    @users = User.all
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = t('success.update')
    else
      flash.now[:error] = @user.errors.full_messages.join(' ')
    end
  end

  def destroy
  end

  private

    def find_user
      @user = User.find(params[:id])
    end

    def auth_user
      raise Error::Forbidden unless @user == Current.user || Current.user.is_admin?
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
