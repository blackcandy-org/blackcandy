# frozen_string_literal: true

require "test_helper"

class BlackCandy::ConfigTest < ActiveSupport::TestCase
  test "should get value from ENV" do
    assert_nil BlackCandy::Config.redis_url

    with_env("REDIS_URL" => "test_redis_url") do
      assert_equal "test_redis_url", BlackCandy::Config.redis_url
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

  test "should get embedded_sidekiq_concurrency value as an integer" do
    assert_nil ENV["EMBEDDED_SIDEKIQ_CONCURRENCY"]
    assert_equal 2, BlackCandy::Config.embedded_sidekiq_concurrency

    with_env("EMBEDDED_SIDEKIQ_CONCURRENCY" => "1") do
      assert_equal 1, BlackCandy::Config.embedded_sidekiq_concurrency
    end
  end

  test "should use redis_url as default value when redis_cache_url did not set" do
    assert_nil ENV["REDIS_URL"]
    assert_nil ENV["REDIS_CACHE_URL"]
    assert_nil BlackCandy::Config.redis_cache_url

    with_env("REDIS_URL" => "test_redis_url") do
      assert_equal "test_redis_url", BlackCandy::Config.redis_cache_url
    end

    with_env("REDIS_URL" => "test_redis_url", "REDIS_CACHE_URL" => "test_redis_cache_url") do
      assert_equal "test_redis_cache_url", BlackCandy::Config.redis_cache_url
    end
  end

  test "should use redis_url as default value when redis_cable_url did not set" do
    assert_nil ENV["REDIS_URL"]
    assert_nil ENV["REDIS_CABLE_UR"]
    assert_nil BlackCandy::Config.redis_cable_url

    with_env("REDIS_URL" => "test_redis_url") do
      assert_equal "test_redis_url", BlackCandy::Config.redis_cable_url
    end

    with_env("REDIS_URL" => "test_redis_url", "REDIS_CABLE_URL" => "test_redis_cable_url") do
      assert_equal "test_redis_cable_url", BlackCandy::Config.redis_cable_url
    end
  end

  test "should use redis_url as default value when redis_sidekiq_url did not set" do
    assert_nil ENV["REDIS_URL"]
    assert_nil ENV["REDIS_SIDEKIQ_URL"]
    assert_nil BlackCandy::Config.redis_sidekiq_url

    with_env("REDIS_URL" => "test_redis_url") do
      assert_equal "test_redis_url", BlackCandy::Config.redis_sidekiq_url
    end

    with_env("REDIS_URL" => "test_redis_url", "REDIS_SIDEKIQ_URL" => "test_redis_sidekiq_url") do
      assert_equal "test_redis_sidekiq_url", BlackCandy::Config.redis_sidekiq_url
    end
  end

  test "should raise error when embedded_sidekiq_concurrency is more than 2" do
    with_env("EMBEDDED_SIDEKIQ_CONCURRENCY" => "3") do
      assert_raises(BlackCandy::Config::ValidationError) do
        BlackCandy::Config.embedded_sidekiq_concurrency
      end
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

  test "when embedded sidekiq is enabled puma threads plus sidekiq concurrency should never be greater than 5" do
    assert_not BlackCandy::Config.embedded_sidekiq?
    assert_equal 5, BlackCandy::Config.puma_max_threads_count

    with_env("EMBEDDED_SIDEKIQ" => "true", "EMBEDDED_SIDEKIQ_CONCURRENCY" => "2") do
      assert_equal 3, BlackCandy::Config.puma_max_threads_count
      assert_equal 3, BlackCandy::Config.puma_min_threads_count
    end

    with_env("EMBEDDED_SIDEKIQ" => "true", "EMBEDDED_SIDEKIQ_CONCURRENCY" => "1") do
      assert_equal 4, BlackCandy::Config.puma_max_threads_count
      assert_equal 4, BlackCandy::Config.puma_min_threads_count
    end
  end
end
