# frozen_string_literal: true

require "test_helper"

class BlackCandy::ConfigTest < ActiveSupport::TestCase
  test "should get value from ENV" do
    assert_nil BlackCandy::Config.media_path

    with_env("MEDIA_PATH" => "test_media_path") do
      assert_equal "test_media_path", BlackCandy::Config.media_path
    end
  end

  test "should get default value when can not find value from ENV" do
    with_env("DB_ADAPTER" => nil) do
      assert_equal "sqlite", BlackCandy::Config.db_adapter
    end
  end

  test "should get nginx_sendfile value as a boolean" do
    assert_nil ENV["NGINX_SENDFILE"]
    assert_not BlackCandy::Config.nginx_sendfile?

    with_env("NGINX_SENDFILE" => "true") do
      assert BlackCandy::Config.nginx_sendfile?
    end
  end

  test "should raise error when database_adapter is not supported" do
    with_env("DB_ADAPTER" => "invalid_adapter") do
      assert_raises(BlackCandy::Config::ValidationError) do
        BlackCandy::Config.db_adapter
      end
    end
  end

  test "should raise error when database_adapter is postgresql but database_url is not set" do
    with_env("DB_ADAPTER" => "postgresql", "DB_URL" => nil) do
      assert_raises(BlackCandy::Config::ValidationError) do
        BlackCandy::Config.db_adapter
      end
    end

    with_env("DB_ADAPTER" => "postgresql", "DB_URL" => "database_url") do
      assert_equal "postgresql", BlackCandy::Config.db_adapter
    end
  end
end
