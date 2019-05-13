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

    task :all do
      status = 0

      %w(rubocop js css).each do |task|
        pid = Process.fork do
          rd_out, wr_out = IO.pipe
          rd_err, wr_err = IO.pipe
          stdout = $stdout.dup
          stderr = $stderr.dup
          $stdout.reopen(wr_out)
          $stderr.reopen(wr_err)

          begin
            Rake::Task["lint:#{task}"].invoke
          ensure
            $stdout.reopen(stdout)
            $stderr.reopen(stderr)
            wr_out.close
            wr_err.close

            IO.copy_stream(rd_out, $stdout)
            IO.copy_stream(rd_err, $stderr)
          end
        end

        Process.waitpid(pid)
        status += $?.exitstatus
      end

      exit(status)
    end
  end
end
