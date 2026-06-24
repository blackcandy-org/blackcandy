# frozen_string_literal: true

require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should get index" do
    login
    get albums_url

    assert_response :success
  end

  test "should update image for album" do
    album = albums(:album1)
    login users(:admin)

    assert_changes -> { album.reload.has_cover_image? } do
      patch album_url(album), params: { album: { cover_image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
    end
  end

  test "should has error flash when failed to update album" do
    login users(:admin)
    patch album_url(albums(:album1)), params: { album: { cover_image: fixture_file_upload("cover_image.gif", "image/gif") } }

    assert flash[:alert].present?
  end

  test "should show album" do
    login
    get album_url(albums(:album1))

    assert_response :success
  end

  test "should edit album" do
    login users(:admin)
    get edit_album_url(albums(:album1))

    assert_response :success
  end

  test "should only admin can edit album" do
    login

    get edit_album_url(albums(:album1))
    assert_response :forbidden

    patch album_url(albums(:album1)), params: { album: { image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
    assert_response :forbidden
  end

  test "should not edit album when is on demo mode" do
    with_env("DEMO_MODE" => "true") do
      login users(:admin)

      get edit_album_url(albums(:album1))
      assert_response :forbidden

      patch album_url(albums(:album1)), params: { album: { image: fixture_file_upload("cover_image.jpg", "image/jpeg") } }
      assert_response :forbidden
    end
  end

  test "should get index via api" do
    get albums_url, as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success

    album = albums(:album1)
    album_response = response.find { |item| item["id"] == album.id }

    assert_equal album.name, album_response["name"]
    assert_equal album.year, album_response["year"]
    assert_equal album.genre, album_response["genre"]
    assert_equal album.artist.name, album_response["artist_name"]
    assert_equal album.artist_id, album_response["artist_id"]
    assert album_response["image_urls"]["small"].present?
    assert album_response["image_urls"]["medium"].present?
    assert album_response["image_urls"]["large"].present?
  end

  test "should show album via api" do
    album = albums(:album1)
    get album_url(album), as: :json, headers: api_token_header(users(:visitor1))
    response = @response.parsed_body

    assert_response :success
    assert_equal album.id, response["id"]
    assert_equal album.name, response["name"]
    assert_equal album.year, response["year"]
    assert_equal album.genre, response["genre"]
    assert_equal album.artist.name, response["artist_name"]
    assert_equal album.artist_id, response["artist_id"]
    assert response["image_urls"]["small"].present?
    assert response["image_urls"]["medium"].present?
    assert response["image_urls"]["large"].present?
    assert_equal album.song_ids, response["songs"].map { |song| song["id"] }
  end

  test "should update image for album via api" do
    album = albums(:album1)

    assert_changes -> { album.reload.has_cover_image? } do
      patch album_url(album),
        params: { album: { cover_image: fixture_file_upload("cover_image.jpg", "image/jpeg") } },
        headers: api_token_header(users(:admin)).merge("Accept" => "application/json")
    end

    assert_response :success
    assert_equal album.id, @response.parsed_body["id"]
  end

  test "should return error response when failed to update album via api" do
    patch album_url(albums(:album1)),
      params: { album: { cover_image: fixture_file_upload("cover_image.gif", "image/gif") } },
      headers: api_token_header(users(:admin)).merge("Accept" => "application/json")

    assert_response :unprocessable_entity
    assert_equal "RecordInvalid", @response.parsed_body["type"]
    assert @response.parsed_body["message"].present?
  end

  test "should paginate index via api with limit param and link header" do
    Album.destroy_all
    5.times { |i| Album.create!(name: "album_#{i}", artist: artists(:artist1)) }

    get albums_url(limit: 2, page: 2), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])

    assert_equal albums_url(limit: 2, page: 1), links["first"]
    assert_equal albums_url(limit: 2, page: 1), links["prev"]
    assert_equal albums_url(limit: 2, page: 3), links["next"]
    assert_equal albums_url(limit: 2, page: 3), links["last"]
  end
end
