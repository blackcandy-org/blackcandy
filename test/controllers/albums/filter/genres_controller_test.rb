# frozen_string_literal: true

require "test_helper"

class Albums::Filter::GenresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get albums_filter_genres_url

    assert_response :success
  end
end
