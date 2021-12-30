# frozen_string_literal: true

unless Rails.env.production?
  require "standard/rake"

  namespace :lint do
    task :js do
      abort("rails lint:js failed") unless system("yarn run eslint 'app/javascript/**/*.js'")
    end

    task :css do
      abort("rails lint:css failed") unless system("yarn run stylelint 'app/assets/stylesheets/**/*.css'")
    end

    task :all do
      require "English"

      status = 0

      %w[standard lint:js lint:css].each do |task|
        pid = Process.fork do
          rd_out, wr_out = IO.pipe
          rd_err, wr_err = IO.pipe
          stdout = $stdout.dup
          stderr = $stderr.dup
          $stdout.reopen(wr_out)
          $stderr.reopen(wr_err)

          begin
            Rake::Task[task].invoke
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
        status += $CHILD_STATUS.exitstatus
      end

      exit(status)
    end
  end
end
