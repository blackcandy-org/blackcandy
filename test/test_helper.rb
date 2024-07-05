# frozen_string_literal: true

require "simplecov"

SimpleCov.start "rails" do
  # After upgrading to Rails 7.1, simplecov cannot collect coverage for files in the lib directory.
  # It seems that the behavior of the Rails test command has changed. I have already tried adding the lib directory to the autoload once path,
  # It works for the development environment, but for the test the database.yml must explicitly require the lib directory. So simplecov
  # will still run after the required file. The result is that the coverage still does not include the file in the lib directory.
  # Still didn't figure out how to solve it, so temporarily add the lib directory to the filter.
  add_filter "/lib/"

  if ENV["CI"]
    require "simplecov-lcov"

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = "coverage/lcov.info"
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
end

require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "minitest/mock"

allowed_sites_for_webmock = [
  "chromedriver.storage.googleapis.com"
]

WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true, allow: allowed_sites_for_webmock)

MediaListener.configure do |config|
  config.service_name = "media_listener_service_test"
end

MediaSyncJob.configure do |config|
  config.parallel_processor_count = 0
end

class MediaFileMock < MediaFile
  class << self
    alias_method :real_file_info, :file_info
  end

  def initialize(file_path, attributes = {})
    @file_path = file_path
    @attributes = attributes
    @mtime = File.mtime(file_path)
  end

  def mtime(path)
    (path.to_s == @file_path.to_s) ? Time.now : @mtime
  end

  def file_info(path)
    file_info = self.class.real_file_info(path)
    (path.to_s == @file_path.to_s) ? file_info.merge(@attributes) : file_info
  end
end

class ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Fix SimpleCov to work with parallel tests, see: https://github.com/simplecov-ruby/simplecov/issues/718#issuecomment-538201587
  parallelize_setup do |worker|
    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do |worker|
    SimpleCov.result
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def clear_media_data
    Artist.delete_all
    Album.delete_all
    Song.delete_all
  end

  def audio_bitrate(file_path)
    WahWah.open(file_path).bitrate
  end

  def create_tmp_dir(from: "")
    tmp_dir = Dir.mktmpdir
    FileUtils.cp_r(File.join(from, "."), tmp_dir) if File.exist? from

    yield tmp_dir
  ensure
    FileUtils.remove_entry(tmp_dir)
  end

  def create_tmp_file(format: "")
    tmp_file = Tempfile.new(["", ".#{format}"])
    yield tmp_file.path
  ensure
    tmp_file.close
    tmp_file.unlink
  end

  def login(user = users(:visitor1))
    post sessions_url, params: {session: {email: user.email, password: "foobar"}}
  end

  def api_token_header(user)
    session = user.sessions.create!
    {authorization: ActionController::HttpAuthentication::Token.encode_credentials(session.signed_id)}
  end

  def fixtures_file_path(file_name)
    Rails.root.join("test", "fixtures", "files", file_name).to_s
  end

  def binary_data(file_path)
    File.read(file_path).force_encoding("BINARY").strip
  end

  def stub_file_metadata(file_path, attributes = {})
    media_file_mock = MediaFileMock.new(file_path, attributes)

    File.stub(:mtime, media_file_mock.method(:mtime)) do
      MediaFile.stub(:file_info, media_file_mock.method(:file_info)) do
        yield
      end
    end
  end

  def with_forgery_protection
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = old
  end

  def with_env(envs = {})
    old_value = {}

    envs.each do |key, value|
      old_value[key] = ENV[key]
      ENV[key] = value
    end

    yield
  ensure
    old_value.each do |key, value|
      ENV[key] = value
    end
  end
end
