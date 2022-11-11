embedded_sidekiq = Rails.configuration.active_job.queue_adapter == :sidekiq && ENV.fetch("EMBEDDED_SIDEKIQ", "true") == "true"

# Accroding to the documentation, we should keep embedded sidekiq concurrency very low, i.e. 1-2
embedded_sidekiq_concurrency = [ENV.fetch("EMBEDDED_SIDEKIQ_CONCURRENCY", 2), 2].min
# A good rule of thumb is that your puma threads + sidekiq concurrency should never be greater than 5
max_threads_for_embedded_sidekiq = 5

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = embedded_sidekiq ? (max_threads_for_embedded_sidekiq - embedded_sidekiq_concurrency) : ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = embedded_sidekiq ? 1 : ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }

threads min_threads_count, max_threads_count

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

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

if embedded_sidekiq
  workers 2

  # Preloading the application is necessary to ensure
  # the configuration in your initializer runs before
  # the boot callback below.
  preload_app!
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
