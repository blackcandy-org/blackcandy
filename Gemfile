source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.0"

# The original asset pipeline for Rails
gem "sprockets-rails", "~> 3.4.2"

# Install Turbo on Rails
gem "turbo-rails", "~> 1.0.0"

# Install Stimulus on Rails
gem "stimulus-rails", "~> 1.0.2"

# Integrate Dart Sass with the asset pipeline in Rails
gem "dartsass-rails", "~> 0.4.0"

# Bundle and transpile JavaScript in Rails
gem "jsbundling-rails", "~> 1.0.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.3.2"

# Use Puma as the app server
gem "puma", "~> 5.6.4"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11.5"

# Get meta data from audio file
gem "wahwah", "~> 1.3.0"

# Use sidekiq for backgroud job
gem "sidekiq", "~> 6.4.0"

# Pagination
gem "pagy", "~> 5.6.6"

# Use redis on cache and sidekiq
gem "redis", "~> 4.0"

gem "redis-objects", "~> 1.5.1"

# For image attachment
gem "carrierwave", "~> 2.2.0"

# For API request
gem "httparty", "~> 0.17.0"

# For browser detection
gem "browser", "~> 2.6.1", require: "browser/browser"

# For PostgreSQL's full text search
gem "pg_search", "~> 2.3.2"

# For sortable list
gem "acts_as_list", "~> 1.0.2"

# For authentication
gem "authlogic", "~> 6.4.1"
gem "bcrypt", "~> 3.1.11"

# For sync on library changes
gem "listen", "~> 3.7.1"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.10.3", require: false

group :development, :test do
  gem "standard", "~> 1.7"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  # Security vulnerability scanner
  gem "brakeman", "~> 5.1.2", require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Memory profiler for ruby
  gem "memory_profiler", "~> 0.9.13", require: false
  # Help to kill N+1 queries and unused eager loading
  gem "bullet", "~> 7.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.36.0"
  gem "cuprite", git: "https://github.com/rubycdp/cuprite", branch: "master"
  gem "webmock", "~> 3.14.0", require: false
  gem "simplecov", "~> 0.21.2", require: false
  gem "simplecov-lcov", "~> 0.8.0", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
