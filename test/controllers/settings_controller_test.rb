# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test 'should show setting' do
    assert_login_access(url: setting_url) do
      assert_response :success
    end
  end

  test 'should update global setting' do
    Setting.update(discogs_token: 'token')

    assert_admin_access(
      method: :patch,
      url: setting_url,
      params: { setting: { discogs_token: 'updated_token' } },
      xhr: true
    ) do
      assert_equal 'updated_token', Setting.discogs_token
    end
  end

  test 'should sync media when media_path setting updated' do
    Setting.update(media_path: 'path')
    mock = MiniTest::Mock.new
    mock.expect(:call, true)

    Media.stub(:sync, mock) do
      assert_admin_access(
        method: :patch,
        url: setting_url,
        params: { setting: { media_path: 'updated_path' } },
        xhr: true
      ) do
        assert_equal 'updated_path', Setting.media_path
        mock.verify
      end
    end
  end
end
