# frozen_string_literal: true

require "test_helper"

class DialogRenderingTest < ActionDispatch::IntegrationTest
  test "renders a placeholder that loads the dialog when the page carries a signed dialog param" do
    login
    get album_url(albums(:album1), dialog: signed_dialog_path("/about"))

    assert_response :success
    assert_select "#js-dialog [hx-get=?][hx-trigger=load][hx-target='#js-dialog']", "/about"
  end

  test "renders no dialog placeholder for an unsigned param" do
    login
    get album_url(albums(:album1), dialog: "/about")

    assert_response :success
    assert_select "#js-dialog [hx-get]", false
  end

  test "renders no dialog placeholder for a tampered param" do
    login
    get album_url(albums(:album1), dialog: signed_dialog_path("/about").swapcase)

    assert_response :success
    assert_select "#js-dialog [hx-get]", false
  end

  test "renders a dialog in the dialog layout, without the app layout" do
    login
    get about_url

    assert_response :success
    assert_select "dialog.c-dialog"
    assert_select "#js-app", false
  end

  test "redirects back to the referer without the dialog param" do
    playlist = playlists(:playlist1)
    login playlist.user

    post playlist_songs_url(playlist),
      params: { song_id: 1 },
      headers: { "Referer" => "http://www.example.com/albums?query=test&dialog=#{signed_dialog_path("/playlists/selections")}" }

    assert_redirected_to "http://www.example.com/albums?query=test"
  end

  test "redirects back to the referer as is when it carries no dialog param" do
    playlist = playlists(:playlist1)
    login playlist.user

    post playlist_songs_url(playlist),
      params: { song_id: 1 },
      headers: { "Referer" => "http://www.example.com/albums?query=test&sort=name" }

    assert_redirected_to "http://www.example.com/albums?query=test&sort=name"
  end

  test "redirects back to the fallback when the referer is not a valid url" do
    playlist = playlists(:playlist1)
    login playlist.user

    post playlist_songs_url(playlist),
      params: { song_id: 1 },
      headers: { "Referer" => "http:// not a url" }

    assert_redirected_to root_url
  end

  private

  def signed_dialog_path(path)
    DialogHelper.verifier.generate(path)
  end
end
