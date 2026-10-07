# frozen_string_literal: true

require "test_helper"

module My
  class RecentlyPlayedControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:visitor1)
    end

    test "should get recently played albums via api" do
      album = albums(:album1)

      @user.add_album_to_recently_played(album)
      @user.add_album_to_recently_played(albums(:album2))

      get my_recently_played_index_url, as: :json, headers: api_token_header(@user)
      response = @response.parsed_body

      assert_response :success
      assert_equal [ albums(:album2).id, album.id ], response.map { |item| item["id"] }
    end

    test "should only get recently played albums of current user via api" do
      users(:admin).add_album_to_recently_played(albums(:album1))

      get my_recently_played_index_url, as: :json, headers: api_token_header(@user)

      assert_response :success
      assert_empty @response.parsed_body
    end
  end
end
