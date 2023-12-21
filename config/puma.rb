require_relative "../lib/black_candy/config"

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
threads BlackCandy::Config.puma_min_threads_count, BlackCandy::Config.puma_max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT", 3000)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

on_booted do
  MediaListener.start if Setting.enable_media_listener? && !MediaListener.running?
end

if ENV["RAILS_ENV"] == "production"
  # Specifies that the worker count should equal the number of processors in production.
  require "concurrent-ruby"
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
  workers worker_count if worker_count > 1

  on_worker_shutdown do
    MediaListener.stop if MediaListener.running?
  end
end

if ENV["RAILS_ENV"] == "development"
  on_thread_exit do
    MediaListener.stop if MediaListener.running?
  end
end

if BlackCandy::Config.embedded_sidekiq?
  sidekiq = nil

  on_worker_boot do
    sidekiq = Sidekiq.configure_embed do |config|
      config.concurrency = 2
    end

    sidekiq.run
  end

  on_worker_shutdown do
    sidekiq&.stop
  end
end
