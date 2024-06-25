# frozen_string_literal: true

class MediaListener
  include Singleton
  include BlackCandy::Configurable

  SERVICE_PATH = File.join(Rails.root, "lib", "daemons", "media_listener_service")

  has_config :service_name, default: "media_listener_service"
  has_config :pid_dir, default: File.join(Rails.root, "tmp", "pids")

  class << self
    delegate :start, :stop, :running?, to: :instance
  end

  def start
    run("start")
  end

  def stop
    run("stop")
  end

  def running?
    pid_file_path = Daemons::PidFile.find_files(self.class.config.pid_dir, self.class.config.service_name).first
    return false unless pid_file_path.present?

    pid_file = Daemons::PidFile.existing(pid_file_path)
    Daemons::Pid.running?(pid_file.pid)
  end

  private

  def run(command)
    system "bundle exec #{SERVICE_PATH} #{command} -d #{self.class.config.pid_dir} -n #{self.class.config.service_name}"
  end
end
