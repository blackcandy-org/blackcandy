# frozen_string_literal: true

require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/mock'
require 'taglib'

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

  def assert_admin_access(request_method, request_url, **request_args)
    login users(:visitor1)
    send(request_method, request_url, **request_args)
    assert_response :forbidden

    teardown_fixtures

    login users(:admin)
    send(request_method, request_url, **request_args)
    yield
  end

  def assert_login_access(request_method, request_url, **request_args)
    send(request_method, request_url, **request_args)
    assert_redirected_to new_session_url

    teardown_fixtures

    login users(:visitor1)
    send(request_method, request_url, **request_args)
    yield
  end

  def assert_self_or_admin_access(current_user, request_method, request_url, **request_args)
    login users(:admin)
    send(request_method, request_url, **request_args)
    yield

    teardown_fixtures

    login current_user
    send(request_method, request_url, **request_args)
    yield

    teardown_fixtures

    login User.where.not(email: current_user.email, is_admin: true).first
    send(request_method, request_url, **request_args)
    assert_response :forbidden
  end
end
