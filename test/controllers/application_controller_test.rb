# frozen_string_literal: true

require "test_helper"

class DummyController < ApplicationController
  def index
    render plain: "OK"
  end

  def show
    redirect_back_with_referer_params(fallback_location: {action: "index"})
  end
end

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get "/dummy_index", to: "dummy#index"
      get "/dummy_show", to: "dummy#show"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "should redirect to new session page when did not logged in" do
    get "/dummy_index"
    assert_redirected_to new_session_url
  end

  test "should require login" do
    login

    get "/dummy_index"
    assert_response :success
  end

  test "should get unauthorized when did not logged in on turbo native agent" do
    get "/dummy_index", headers: {"User-Agent" => "Black Candy iOS"}
    assert_response :unauthorized

    get "/dummy_index", headers: {"User-Agent" => "Black Candy Android"}
    assert_response :unauthorized
  end

  test "should redirect with referer url parmas" do
    login

    get "/dummy_show", params: {referer_url: "/"}
    assert_redirected_to "/"
  end
end
