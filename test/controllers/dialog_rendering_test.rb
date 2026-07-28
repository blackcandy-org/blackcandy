# frozen_string_literal: true

require "test_helper"

class DialogRenderingTest < ActionDispatch::IntegrationTest
  test "renders dialog frame when carrying a signed dialog param" do
    login
    get album_url(albums(:album1), dialog: signed_dialog_path("/about")), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog turbo-frame#turbo-dialog-content[src=?]", "/about"
  end

  test "renders an empty dialog frame for an unsigned param" do
    login
    get album_url(albums(:album1), dialog: "/about"), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog-content", false
  end

  test "renders an empty dialog frame for a tampered param" do
    login
    get album_url(albums(:album1), dialog: signed_dialog_path("/about").swapcase), headers: { "Turbo-Frame" => "turbo-dialog" }

    assert_response :success
    assert_select "turbo-frame#turbo-dialog-content", false
  end

  test "renders the full page with an eager dialog frame on a non-frame request" do
    login
    get album_url(albums(:album1), dialog: signed_dialog_path("/about"))

    assert_response :success
    assert_select "turbo-frame#turbo-dialog turbo-frame#turbo-dialog-content[src=?]", "/about"
  end

  private

  def signed_dialog_path(path)
    DialogHelper.verifier.generate(path)
  end
end
