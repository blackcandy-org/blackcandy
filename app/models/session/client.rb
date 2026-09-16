# frozen_string_literal: true

module Session::Client
  extend ActiveSupport::Concern

  IOS_APP_PATTERN = /Black Candy iOS/
  ANDROID_APP_PATTERN = /Black Candy Android/

  IOS_APP_NAME = "Black Candy iOS"
  ANDROID_APP_NAME = "Black Candy Android"

  def ios?
    user_agent.to_s.match?(IOS_APP_PATTERN)
  end

  def android?
    user_agent.to_s.match?(ANDROID_APP_PATTERN)
  end

  def client_name
    return IOS_APP_NAME if ios?
    return ANDROID_APP_NAME if android?

    browser.known? ? browser.name : I18n.t("label.unknown_client")
  end

  def client_platform
    browser.platform.name unless browser.platform.unknown?
  end

  def browser
    @browser ||= Browser.new(user_agent.to_s)
  end
end
