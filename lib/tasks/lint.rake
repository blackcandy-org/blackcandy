# frozen_string_literal: true

unless Rails.env.production?
  require "standard/rake"

  namespace :lint do
    task :js do
      abort("rails lint:js failed") unless system("npx standard 'app/javascript/**/*.js'")
    end

    task :css do
      abort("rails lint:css failed") unless system("npx stylelint 'app/assets/stylesheets/**/*.scss'")
    end

    task :erb do
      abort("rails lint:erb failed") unless system("bundle exec erblint --lint-all")
    end

    task all: %w[standard erb js css]
  end
end
