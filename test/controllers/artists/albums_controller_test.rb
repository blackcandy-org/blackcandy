# frozen_string_literal: true

require 'test_helper'

class Artists::AlbumsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: artist_albums_path(artists :artist1)) do
      assert_response :success
    end
  end

  test 'should redirect to not found page when artists have no albums' do
    empty_artist = Artist.create

    assert_login_access(url: artist_albums_path(empty_artist)) do
      assert_response :not_found
    end
  end
end
