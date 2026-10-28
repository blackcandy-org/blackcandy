# frozen_string_literal: true

require "test_helper"

class Playlists::SelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get playlists_selections_url

    assert_response :success
  end

  test "should render only the next page's playlists for infinite scroll" do
    login users(:admin)
    get playlists_selections_url(limit: 1, page: 2), headers: { "HX-Request" => "true", "HX-Request-Type" => "partial" }

    assert_response :success
    assert_includes response.body, playlists(:playlist2).name
    assert_not_includes response.body, playlists(:playlist1).name
  end
end
