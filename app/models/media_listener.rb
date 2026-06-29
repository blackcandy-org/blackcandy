# frozen_string_literal: true

class MediaListener
  include BlackCandy::Configurable

  SERVICE_PATH = File.join(Rails.root, "lib", "daemons", "media_listener_service")

  has_config :service_name, default: "media_listener_service", env_prefix: "media_listener"
  has_config :pid_dir, default: File.join(Rails.root, "tmp", "pids"), env_prefix: "media_listener"

  class << self
    def start
      run("start")
    end

    def stop
      run("stop")
    end

    def running?
      pid_file_path = Daemons::PidFile.find_files(config.pid_dir, config.service_name).first
      return false unless pid_file_path.present?

      pid_file = Daemons::PidFile.existing(pid_file_path)
      Daemons::Pid.running?(pid_file.pid)
    end

    private

    def run(command)
      system "bundle exec #{SERVICE_PATH.shellescape} #{command.shellescape} -d #{config.pid_dir.shellescape} -n #{config.service_name.shellescape}"
    end
  end
end
