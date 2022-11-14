if Rails.configuration.active_job.queue_adapter == :sidekiq
  Sidekiq.configure_server do |config|
    config.redis = {url: ENV.fetch("REDIS_SIDEKIQ_URL", ENV["REDIS_URL"])}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: ENV.fetch("REDIS_SIDEKIQ_URL", ENV["REDIS_URL"])}
  end
end
