# frozen_string_literal: true

class MediaListener
  SERVICE_NAME = "media_listener_service"
  PID_DIR = File.join(Rails.root, "tmp", "pids")
  SERVICE_PATH = File.join(Rails.root, "lib", "daemons", "media_listener_service")

  class << self
    def start
      run("start")
    end

    def stop
      run("stop")
    end

    def running?
      pid_file_path = Daemons::PidFile.find_files(PID_DIR, SERVICE_NAME).first
      return false unless pid_file_path.present?

      pid_file = Daemons::PidFile.existing(pid_file_path)
      Daemons::Pid.running?(pid_file.pid)
    end

    private

    def run(command)
      system "bundle exec #{SERVICE_PATH} #{command} -d #{PID_DIR} -n #{SERVICE_NAME}"
    end
  end
end
