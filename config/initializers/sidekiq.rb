if BlackCandy::Config.redis_sidekiq_url.present?
  Sidekiq.configure_server do |config|
    config.redis = {url: BlackCandy::Config.redis_sidekiq_url}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: BlackCandy::Config.redis_sidekiq_url}
  end
end
