# frozen_string_literal: true

require "test_helper"

class DialogRenderingTest < ActionDispatch::IntegrationTest
  test "renders dialog frame when carrying a dialog param" do
    login
    get album_url(albums(:album1), dialog: "/about"), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog turbo-frame#turbo-dialog-content[src=?]", "/about"
  end

  test "renders an empty dialog frame for a param that is not a dialog path" do
    login
    get album_url(albums(:album1), dialog: "/songs"), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog-content", false
  end

  test "renders an empty dialog frame for an external param" do
    login
    get album_url(albums(:album1), dialog: "https://evil.com/about"), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog-content", false
  end

  test "renders an empty dialog frame for an unroutable param" do
    login
    get album_url(albums(:album1), dialog: "/not-a-real-route"), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog-content", false
  end

  test "renders the full page with an eager dialog frame on a non-frame request" do
    login
    get album_url(albums(:album1), dialog: "/about")

    assert_response :success
    assert_select "turbo-frame#turbo-dialog turbo-frame#turbo-dialog-content[src=?]", "/about"
  end
end
