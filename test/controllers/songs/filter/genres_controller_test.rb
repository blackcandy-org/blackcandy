# frozen_string_literal: true

require "test_helper"

class Songs::Filter::GenresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get songs_filter_genres_url

    assert_response :success
  end
end
