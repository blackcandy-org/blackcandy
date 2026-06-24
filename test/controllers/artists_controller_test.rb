# frozen_string_literal: true

require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    login
    get artists_url

    assert_response :success
  end

  test "should show artist" do
    login
    get artist_url(artists(:artist1))

    assert_response :success
  end

  test "should edit artist" do
    login users(:admin)
    get edit_artist_url(artists(:artist1))

    assert_response :success
  end

  test "should only admin can edit artist" do
    login

    get edit_artist_url(artists(:artist1))
    assert_response :forbidden

    patch artist_url(artists(:artist1)), params: { artist: { image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
    assert_response :forbidden
  end

  test "should not edit artist when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get edit_artist_url(artists(:artist1))
      assert_response :forbidden

      patch artist_url(artists(:artist1)), params: { artist: { image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
      assert_response :forbidden
    end
  end

  test "should update image for artist" do
    artist = artists(:artist1)
    login users(:admin)

    assert_changes -> { artist.reload.has_cover_image? } do
      patch artist_url(artist), params: { artist: { cover_image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
    end
  end

  test "should has error flash when failed to update artist" do
    login users(:admin)
    patch artist_url(artists(:artist1)), params: { artist: { cover_image: fixture_file_upload("cover_image.gif", "image/gif") } }

    assert flash[:alert].present?
  end

  test "should get index via api" do
    get artists_url, as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success

    artist = artists(:artist1)
    artist_response = response.find { |item| item["id"] == artist.id }

    assert_equal artist.name, artist_response["name"]
    assert_equal artist.various, artist_response["is_various"]
    assert artist_response["image_urls"]["small"].present?
    assert artist_response["image_urls"]["medium"].present?
    assert artist_response["image_urls"]["large"].present?
  end

  test "should update image for artist via api" do
    artist = artists(:artist1)

    assert_changes -> { artist.reload.has_cover_image? } do
      patch artist_url(artist),
        params: { artist: { cover_image: fixture_file_upload("cover_image.jpg", "image/jpeg") } },
        headers: api_token_header(users(:admin)).merge("Accept" => "application/json")
    end

    assert_response :success
    assert_equal artist.id, @response.parsed_body["id"]
  end

  test "should return error response when failed to update artist via api" do
    patch artist_url(artists(:artist1)),
      params: { artist: { cover_image: fixture_file_upload("cover_image.gif", "image/gif") } },
      headers: api_token_header(users(:admin)).merge("Accept" => "application/json")

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should paginate index via api with limit param and link header" do
    Artist.destroy_all
    5.times { |i| Artist.create!(name: "artist_#{i}") }

    get artists_url(limit: 2, page: 2), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])

    assert_equal artists_url(limit: 2, page: 1), links["first"]
    assert_equal artists_url(limit: 2, page: 1), links["prev"]
    assert_equal artists_url(limit: 2, page: 3), links["next"]
    assert_equal artists_url(limit: 2, page: 3), links["last"]
  end

  test "should show artist via api" do
    artist = artists(:artist1)
    get artist_url(artist), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal artist.id, response["id"]
    assert_equal artist.name, response["name"]
    assert_equal artist.various, response["is_various"]
    assert response["image_urls"]["small"].present?
    assert response["image_urls"]["medium"].present?
    assert response["image_urls"]["large"].present?
    assert_equal artist.albums.ids, response["albums"].map { |album| album["id"] }
  end
end
