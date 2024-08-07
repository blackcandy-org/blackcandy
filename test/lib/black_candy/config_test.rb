# frozen_string_literal: true

require "test_helper"

class BlackCandy::ConfigTest < ActiveSupport::TestCase
  test "should get value from ENV" do
    assert_nil BlackCandy.config.media_path

    with_env("MEDIA_PATH" => "test_media_path") do
      assert_equal "test_media_path", BlackCandy.config.media_path
    end
  end

  test "should get default value when can not find value from ENV and value is not set" do
    with_env("DB_ADAPTER" => nil) do
      BlackCandy.configure do |config|
        config.db_adapter = nil
      end

      assert_equal "sqlite", BlackCandy.config.db_adapter
    end

    with_env("DB_ADAPTER" => nil) do
      BlackCandy.configure do |config|
        config.db_adapter = "postgresql"
      end

      assert_equal "postgresql", BlackCandy.config.db_adapter
    end

    with_env("DB_ADAPTER" => "postgresql") do
      BlackCandy.configure do |config|
        config.db_adapter = nil
      end

      assert_equal "postgresql", BlackCandy.config.db_adapter
    end
  end

  test "should get nginx_sendfile value as a boolean" do
    assert_nil ENV["NGINX_SENDFILE"]
    assert_not BlackCandy.config.nginx_sendfile?

    with_env("NGINX_SENDFILE" => "true") do
      assert BlackCandy.config.nginx_sendfile?
    end
  end

  test "should raise error when database_adapter is not supported" do
    with_env("DB_ADAPTER" => "invalid_adapter") do
      assert_raises(BlackCandy::Config::ValidationError) do
        BlackCandy.config.db_adapter
      end
    end
  end

  test "should raise error when database_adapter is postgresql but database_url is not set in production environment" do
    with_env("DB_ADAPTER" => "postgresql", "DB_URL" => nil, "RAILS_ENV" => "production") do
      assert_raises(BlackCandy::Config::ValidationError) do
        BlackCandy.config.db_adapter
      end
    end

    with_env("DB_ADAPTER" => "postgresql", "DB_URL" => "database_url", "RAILS_ENV" => "production") do
      assert_equal "postgresql", BlackCandy.config.db_adapter
    end
  end
end
