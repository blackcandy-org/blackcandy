# frozen_string_literal: true

require 'test_helper'

class ScopedSettingTest < ActiveSupport::TestCase
  test 'should have AVAILABLE_SETTINGS constant' do
    assert_equal [:theme], User::AVAILABLE_SETTINGS
  end

  test 'should update settings' do
    user = users(:visitor1)
    assert_equal 'dark', user.theme

    user.theme = 'light'
    assert_equal 'light', user.reload.theme
  end

  test 'should avoid others option value when set available_options' do
    user = users(:visitor1)
    assert_equal 'dark', user.theme

    user.theme = 'fake_theme'
    assert_equal 'dark', user.reload.theme
  end
end
