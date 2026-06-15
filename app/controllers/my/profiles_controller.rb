# frozen_string_literal: true

module My
  class ProfilesController < ApplicationController
    layout "settings"

    before_action :require_non_demo_mode

    def edit
      @user = Current.user
    end

    def update
      @user = Current.user
      @user.update!(user_params)

      respond_to do |format|
        format.html { redirect_to edit_my_profile_path, notice: t("notice.updated") }
        format.json { render partial: "users/user", locals: { user: @user } }
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def require_non_demo_mode
      raise BlackCandy::Forbidden if BlackCandy.config.demo_mode?
    end
  end
end
