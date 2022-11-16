# frozen_string_literal: true

unless Rails.env.production?
  require "standard/rake"

  namespace :lint do
    task :js do
      abort("rails lint:js failed") unless system("yarn run standard 'app/javascript/**/*.js'")
    end

    task :css do
      abort("rails lint:css failed") unless system("yarn run stylelint 'app/assets/stylesheets/**/*.scss'")
    end

    task all: %w[standard js css]
  end
end
