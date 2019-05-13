# frozen_string_literal: true

unless Rails.env.production?
  require 'rubocop/rake_task'

  namespace :lint do
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.fail_on_error = false
    end

    task :js do
      system("yarn run eslint 'app/frontend/**/*.js'")
    end

    task :css do
      system("yarn run stylelint 'app/frontend/**/*.css'")
    end

    task all: [:rubocop, :js, :css]
  end
end
