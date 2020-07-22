# frozen_string_literal: true

require 'test_helper'

class Artists::AppearsOnAlbumsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: artist_appears_on_albums_path(artists :artist1)) do
      assert_response :success
    end
  end

  test 'should redirect to not found page when artists have no albums' do
    assert artists(:artist2).appears_on_albums.empty?
    assert_login_access(url: artist_appears_on_albums_path(artists :artist2)) do
      assert_response :not_found
    end
  end
end
