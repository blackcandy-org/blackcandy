# frozen_string_literal: true

require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/mock'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def new_user(attributes = {})
    User.new({ password: 'foobar' }.merge(attributes))
  end

  def clear_media_data
    Artist.destroy_all
    Album.destroy_all
    Song.destroy_all
  end

  def audio_bitrate(file_path)
    WahWah.open(file_path).bitrate
  end

  def create_tmp_dir(from: '')
    tmp_dir = Dir.mktmpdir
    FileUtils.cp_r(File.join(from, '.'), tmp_dir) if File.exist? from

    yield tmp_dir
  ensure
    FileUtils.remove_entry(tmp_dir)
  end

  def create_tmp_file(format: '')
    tmp_file = Tempfile.new(['', ".#{format}"])
    yield tmp_file.path
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def login(user)
    post session_url, params: { email: user.email, password: 'foobar' }
  end

  def logout
    delete session_url
  end

  def fixtures_file_path(file_name)
    Rails.root.join('test', 'fixtures', 'files', file_name).to_s
  end

  def binary_data(file_path)
    File.read(file_path).force_encoding('BINARY').strip
  end

  def media_file_info_stub(file_path, attributes = {})
    proc do |media_file_path|
      file_info = MediaFile.send(:get_tag_info, media_file_path).merge(
        file_path: media_file_path,
        md5_hash: MediaFile.send(:get_md5_hash, media_file_path)
      )

      media_file_path.to_s == file_path.to_s ? file_info.merge(**attributes, md5_hash: 'new_md5_hash') : file_info
    end
  end
end

class ActionDispatch::IntegrationTest
  def assert_admin_access(url:, method: :get, **args)
    login users(:visitor1)
    send(method, url, **args)
    assert_response :forbidden

    login users(:admin)
    send(method, url, **args)
    yield users(:admin)
  end

  def assert_login_access(url:, user: users(:visitor1), method: :get, **args)
    logout
    send(method, url, **args)
    assert_redirected_to new_session_url

    login user
    send(method, url, **args)
    yield user
  end

  def assert_self_or_admin_access(url:, user:, method: :get, **args)
    login User.where.not(email: user.email).where.not(is_admin: true).first
    send(method, url, **args)
    assert_response :forbidden

    login users(:admin)
    send(method, url, **args)
    yield

    login user
    send(method, url, **args)
    yield
  end

  def assert_self_access(url:, user:, method: :get, **args)
    login User.where.not(email: user.email).first
    send(method, url, **args)
    assert_response :forbidden

    login user
    send(method, url, **args)
    yield user
  end
end
