# frozen_string_literal: true

require "simplecov"

SimpleCov.start "rails" do
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

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def new_user(attributes = {})
    User.new({password: "foobar"}.merge(attributes))
  end

  def clear_media_data
    Artist.destroy_all
    Album.destroy_all
    Song.destroy_all
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
    post session_url, params: {user_session: {email: user.email, password: "foobar"}}
  end

  def api_token_header(user)
    {authorization: ActionController::HttpAuthentication::Token.encode_credentials(user.api_token)}
  end

  def fixtures_file_path(file_name)
    Rails.root.join("test", "fixtures", "files", file_name).to_s
  end

  def binary_data(file_path)
    File.read(file_path).force_encoding("BINARY").strip
  end

  def media_file_info_stub(file_path, attributes = {})
    proc do |media_file_path|
      file_info = MediaFile.send(:get_tag_info, media_file_path).merge(
        file_path: media_file_path.to_s,
        file_path_hash: MediaFile.get_md5_hash(media_file_path),
        md5_hash: MediaFile.get_md5_hash(media_file_path, with_mtime: true)
      )

      (media_file_path.to_s == file_path.to_s) ? file_info.merge(**attributes, md5_hash: "new_md5_hash") : file_info
    end
  end

  def with_forgery_protection
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = old
  end
end
