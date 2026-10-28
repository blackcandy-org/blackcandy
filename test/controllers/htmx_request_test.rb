# frozen_string_literal: true

require "test_helper"

class HtmxRequestTest < ActionDispatch::IntegrationTest
  test "has htmx load a page without the app layout in full" do
    get new_session_url, headers: { "HX-Request" => "true" }

    assert_response :success
    assert_equal new_session_url, response.headers["HX-Redirect"]
  end

  test "has htmx load a page without the app layout in full when restoring history" do
    get new_session_url
    asset_version = hx_headers["X-Asset-Version"]

    get new_session_url, headers: { "HX-History-Restore-Request" => "true", "X-Asset-Version" => asset_version }

    assert_response :success
    assert_equal new_session_url, response.headers["HX-Redirect"]
  end

  test "has htmx load an error page in full" do
    login
    get album_url(id: "missing"), headers: { "HX-Request" => "true" }

    assert_response :not_found
    assert_equal album_url(id: "missing"), response.headers["HX-Redirect"]
  end

  test "renders a page without the app layout as is for a request not from htmx" do
    get new_session_url

    assert_response :success
    assert_nil response.headers["HX-Redirect"]
  end

  test "renders a page with the app layout for a boosted request" do
    login
    get albums_url
    asset_version = hx_headers["X-Asset-Version"]

    get albums_url, headers: { "HX-Request" => "true", "HX-Boosted" => "true", "X-Asset-Version" => asset_version }

    assert_response :success
    assert_nil response.headers["HX-Redirect"]
    assert_select "#js-app[hx-history-elt]"
  end

  test "doesn't boost pages without the app layout" do
    get new_session_url

    assert_equal "false", inherited_hx_boost(css_select("form").first)
  end

  test "takes the asset version from the digests in the page's asset paths" do
    get new_session_url

    js_digest = css_select("script[src*='/application-']").first["src"][/-(\h+)\.js\z/, 1]
    css_digest = css_select("link[rel=stylesheet][href*='/application-']").first["href"][/-(\h+)\.css\z/, 1]
    assert_equal "#{js_digest}-#{css_digest}", hx_headers["X-Asset-Version"]
  end

  test "has htmx load a page in full after a deploy changes the assets" do
    login
    get albums_url, headers: { "HX-Request" => "true", "HX-Boosted" => "true", "X-Asset-Version" => "before-deploy" }

    assert_response :success
    assert_equal albums_url, response.headers["HX-Redirect"]
    assert_empty response.body
  end

  test "has htmx load a page in full after a deploy when restoring history" do
    login
    get albums_url, headers: { "HX-History-Restore-Request" => "true", "X-Asset-Version" => "before-deploy" }

    assert_response :success
    assert_equal albums_url, response.headers["HX-Redirect"]
  end

  test "handles htmx requests that don't load a page as usual after a deploy" do
    login
    get albums_url, headers: { "HX-Request" => "true", "X-Asset-Version" => "before-deploy" }

    assert_response :success
    assert_nil response.headers["HX-Redirect"]

    post favorite_playlist_songs_url, params: { song_id: 3 }, headers: { "HX-Request" => "true", "HX-Boosted" => "true", "X-Asset-Version" => "before-deploy" }

    assert_response :redirect
    assert_nil response.headers["HX-Redirect"]
  end

  test "varies on the htmx request headers" do
    get new_session_url

    assert_includes response.headers["Vary"], "HX-Request"
    assert_includes response.headers["Vary"], "HX-Request-Type"
    assert_includes response.headers["Vary"], "HX-History-Restore-Request"
  end

  test "sends the CSRF token with htmx requests that don't come from a form" do
    login

    with_forgery_protection do
      get albums_url
      token = hx_headers["X-CSRF-Token"]

      post favorite_playlist_songs_url, params: { song_id: 3 }, headers: { "HX-Request" => "true" }
      assert_response :unprocessable_entity

      post favorite_playlist_songs_url, params: { song_id: 3 }, headers: { "HX-Request" => "true", "X-CSRF-Token" => token }
      assert_response :redirect
    end
  end

  private

  def hx_headers
    JSON.parse(css_select("body").first["hx-headers:inherited"])
  end

  # htmx inherits hx-boost from the closest ancestor that sets hx-boost:inherited.
  def inherited_hx_boost(element)
    element.ancestors.filter_map { |node| node["hx-boost:inherited"] if node.element? }.first
  end
end
