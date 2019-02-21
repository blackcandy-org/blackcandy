# frozen_string_literal: true

unless Rails.env.production?
  require 'rubocop/rake_task'

  namespace :lint do
    RuboCop::RakeTask.new

    task :js do
      unless system("yarn run eslint 'app/frontend/**/*.js'")
        abort('rails lint:js failed')
      end
    end

    task :css do
      unless system("yarn run stylelint 'app/frontend/**/*.css'")
        abort('rails lint:css failed')
      end
    end

    task all: [:rubocop, :js, :css]
  end
end
