source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.2.0"

# Deliver assets for Rails
gem "propshaft", "~> 1.1.0"

# Install Turbo on Rails
gem "turbo-rails", "~> 1.5.0"

# Install Stimulus on Rails
gem "stimulus-rails", "~> 1.3.4"

# Bundle and process CSS in Rails
gem "cssbundling-rails", "~> 1.4.0"

# Bundle and transpile JavaScript in Rails
gem "jsbundling-rails", "~> 1.3.0"

# Use Puma as the app server
gem "puma", "~> 6.4.0"

# Default database
gem "sqlite3", "~> 2.1.0"

# Cache store
gem "solid_cache", "~> 1.0.0"

# Background job processing
gem "solid_queue", "~> 1.0.0"

# Action Cable adapter
gem "solid_cable", "~> 3.0.0"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.13.0"

# Get meta data from audio file
gem "wahwah", "~> 1.6.0"

# Pagination
gem "pagy", "~> 6.0.0"

# For Active Storage variants
gem "image_processing", "~> 1.13"

# For API request
gem "httparty", "~> 0.22.0"

# For browser detection
gem "browser", "~> 6.0.0"

# For searching
gem "ransack", "~> 4.2.0"

# For sortable list
gem "acts_as_list", "~> 1.2.0"

# For password encryption
gem "bcrypt", "~> 3.1.11"

# For sync on library changes
gem "listen", "~> 3.9.0"

# For parallel media sync
gem "parallel", "~> 1.25.0"

# For daemonize library sync process
gem "daemons", "~> 1.4.0"

# Optional support for postgresql as database
gem "pg", "~> 1.5.4"

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.8", require: false

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.0", require: false

group :development, :test do
  gem "standard", "~> 1.25.0"
  gem "standard-rails"
  gem "erb_lint", "~> 0.4.0", require: false
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Memory profiler for ruby
  gem "memory_profiler", "~> 0.9.13", require: false
  # Help to kill N+1 queries and unused eager loading
  gem "bullet", "~> 7.2.0"
  # For deployment
  gem "kamal", "~> 1.4.0"
end

group :test do
  gem "capybara", "~> 3.40.0"
  gem "cuprite", "~> 0.14.3"
  gem "webmock", "~> 3.18.0", require: false
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-lcov", "~> 0.8.0", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
