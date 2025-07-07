# frozen_string_literal: true

unless Rails.env.production?
  namespace :lint do
    task :js do
      abort("rails lint:js failed") unless system("npx standard 'app/javascript/**/*.js'")
    end

    task :css do
      abort("rails lint:css failed") unless system("npx stylelint 'app/assets/stylesheets/**/*.scss'")
    end

    task :erb do
      abort("rails lint:erb failed") unless system("bundle exec erb_lint --lint-all")
    end

    task :rb do
      abort("rails lint:rb failed") unless system("./bin/rubocop")
    end

    task all: %w[rb erb js css]
  end
end
