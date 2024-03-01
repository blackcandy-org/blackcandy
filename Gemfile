source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.1.0"

# Deliver assets for Rails
gem "propshaft", "~> 0.7.0"

# Install Turbo on Rails
gem "turbo-rails", "~> 1.5.0"

# Install Stimulus on Rails
gem "stimulus-rails", "~> 1.2.1"

# Bundle and process CSS in Rails
gem "cssbundling-rails", "~> 1.4.0"

# Bundle and transpile JavaScript in Rails
gem "jsbundling-rails", "~> 1.3.0"

# Use Puma as the app server
gem "puma", "~> 6.4.0"

# Default database
gem "sqlite3", "~> 1.7.0"

# Cache store
gem "solid_cache", "~> 0.4.2"

# Background job processing
gem "solid_queue", "~> 0.2.1"

# Default stack for cache and pub/sub
gem "litestack", "~> 0.4.2"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11.5"

# Get meta data from audio file
gem "wahwah", "~> 1.5.0"

# Pagination
gem "pagy", "~> 6.0.0"

# For Active Storage variants
gem "image_processing", "~> 1.12"

# For API request
gem "httparty", "~> 0.21.0"

# For browser detection
gem "browser", "~> 5.3.1"

# For searching
gem "ransack", "~> 4.1.0"

# For sortable list
gem "acts_as_list", "~> 1.1.0"

# For password encryption
gem "bcrypt", "~> 3.1.11"

# For sync on library changes
gem "listen", "~> 3.8.0"

# For daemonize library sync process
gem "daemons", "~> 1.4.0"

# Optional support for postgresql as database
gem "pg", "~> 1.5.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.17.0", require: false

group :development, :test do
  gem "standard", "~> 1.25.0"
  gem "standard-rails"
  gem "erb_lint", "~> 0.4.0", require: false
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Memory profiler for ruby
  gem "memory_profiler", "~> 0.9.13", require: false
  # Help to kill N+1 queries and unused eager loading
  gem "bullet", "~> 7.1.0"
  # For deployment
  gem "kamal", "~> 0.16.1"
end

group :test do
  gem "capybara", "~> 3.39.0"
  gem "cuprite", "~> 0.14.3"
  gem "webmock", "~> 3.18.0", require: false
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-lcov", "~> 0.8.0", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
