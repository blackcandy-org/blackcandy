# frozen_string_literal: true

require "test_helper"

class DummyPlayableController < ApplicationController
  include Playable
end

class PlayableTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get "/dummy_play", to: "dummy_playable#play"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "should raise error when find_all_song_ids method did not implemented" do
    login

    assert_raises(NotImplementedError) do
      get "/dummy_play"
    end
  end
end
