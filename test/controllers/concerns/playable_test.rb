# frozen_string_literal: true

require "test_helper"

class DummyPlayableController < ApplicationController
  include Playable

  private

  def find_all_song_ids
    @song_ids = [1, 2, 3]
  end
end

class NotImplementedDummyPlayableController < ApplicationController
  include Playable
end

class PlayableTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      post "/not_implemented_dummy_play", to: "not_implemented_dummy_playable#play"
      post "/dummy_play", to: "dummy_playable#play"
    end

    login
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "should raise error when find_all_song_ids method did not implemented" do
    assert_raises(NotImplementedError) do
      post "/not_implemented_dummy_play"
    end
  end
end
