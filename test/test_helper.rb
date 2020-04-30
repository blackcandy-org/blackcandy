# frozen_string_literal: true

require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/mock'
require 'taglib'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.orm = :active_record

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

  def update_media_tag(file_path, attributes = {})
    TagLib::FileRef.open(file_path.to_s) do |file|
      unless file.null?
        tag = file.tag

        attributes.each do |key, value|
          tag.send("#{key}=", value)
        end

        file.save
      end
    end
  end

  def audio_bitrate(file_path)
    TagLib::FileRef.open(file_path.to_s) do |file|
      raise if file.null?

      file.audio_properties.bitrate
    end
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

  def flush_redis
    Redis::Objects.redis.flushdb
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
end

class ActionDispatch::IntegrationTest
  include Turbolinks::Assertions

  def assert_admin_access(method: :get, url:, **args)
    login users(:visitor1)
    send(method, url, **args)
    assert_response :forbidden

    login users(:admin)
    send(method, url, **args)
    yield users(:admin)
  end

  def assert_login_access(user: users(:visitor1), method: :get, url:, **args)
    logout
    send(method, url, **args)
    assert_redirected_to new_session_url

    login user
    send(method, url, **args)
    yield user
  end

  def assert_self_or_admin_access(method: :get, user:, url:, **args)
    login User.where.not(email: user.email).where.not(is_admin: true).first
    send(method, url, **args)
    assert_response :forbidden

    DatabaseCleaner.cleaning do
      login users(:admin)
      send(method, url, **args)
      yield
    end

    login user
    send(method, url, **args)
    yield
  end

  def assert_self_access(user:, method: :get, url:, **args)
    login User.where.not(email: user.email).first
    send(method, url, **args)
    assert_response :forbidden

    login user
    send(method, url, **args)
    yield user
  end
end
