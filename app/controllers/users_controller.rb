# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
  end
end
