# frozen_string_literal: true

require 'application_system_test_case'

class SettingSystemTest < ApplicationSystemTestCase
  setup do
    login_as users(:admin)
  end

  test 'update theme' do
    visit setting_url

    choose('user_theme_light')
    click_on('test-setting-theme-save')

    assert_text('Updated successfully')
  end

  test 'update media path' do
    visit setting_url

    fill_in('setting_media_path', with: Rails.root.join('test/fixtures/files').to_s)
    click_on('Sync')

    assert_selector('#js-global-loader', visible: true)
  end

  test 'update discogs token' do
    visit setting_url

    fill_in('setting_discogs_token', with: 'fake_token')
    click_on('test-setting-discogs-token-save')

    assert_text('Updated successfully')
    assert_equal 'fake_token', find_field('setting_discogs_token').value
  end
end
