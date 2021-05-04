# frozen_string_literal: true

require 'test_helper'

class Dialog::PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: dialog_playlists_url) do
      assert_response :success
    end
  end
end
