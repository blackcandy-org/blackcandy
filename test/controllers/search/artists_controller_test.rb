# frozen_string_literal: true

require "test_helper"

class Search::ArtistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get search_artists_url(query: "test")

    assert_response :success
  end

  test "should render only the next page's artists for infinite scroll" do
    3.times { |i| Artist.create!(name: "pager_artist_#{i}") }

    login
    get search_artists_url(query: "pager_", limit: 1, page: 2), headers: { "HX-Request" => "true", "HX-Request-Type" => "partial" }

    assert_response :success
    assert_includes response.body, "pager_artist_1"
    assert_not_includes response.body, "pager_artist_0"
  end

  test "should get index via api" do
    get search_artists_url(query: "1"), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_includes @response.parsed_body.map { |a| a["name"] }, artists(:artist1).name
  end

  test "should paginate index via api with limit param and link header" do
    Artist.destroy_all
    5.times { |i| Artist.create!(name: "pager_artist_#{i}") }

    get search_artists_url(query: "pager_", limit: 2, page: 2), as: :json, headers: api_token_header(users(:visitor1))

    assert_response :success
    assert_equal 2, @response.parsed_body.size

    links = parse_link_header(@response.headers["link"])
    assert_equal search_artists_url(query: "pager_", limit: 2, page: 1), links["first"]
    assert_equal search_artists_url(query: "pager_", limit: 2, page: 1), links["prev"]
    assert_equal search_artists_url(query: "pager_", limit: 2, page: 3), links["next"]
    assert_equal search_artists_url(query: "pager_", limit: 2, page: 3), links["last"]
  end
end
