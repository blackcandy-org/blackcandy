# frozen_string_literal: true

require "test_helper"

class DummyController < ApplicationController
  def index
    render plain: "OK"
  end
end

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get "/dummy_index", to: "dummy#index"
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
    get "/dummy_index", headers: {"User-Agent" => "Turbo Native iOS"}
    assert_response :unauthorized

    get "/dummy_index", headers: {"User-Agent" => "Turbo Native Android"}
    assert_response :unauthorized
  end
end
