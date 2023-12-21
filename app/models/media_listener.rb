# frozen_string_literal: true

class MediaListener
  include Singleton

  SERVICE_PATH = File.join(Rails.root, "lib", "daemons", "media_listener_service")
  class Config
    DEFAULTS = {
      service_name: "media_listener_service",
      pid_dir: File.join(Rails.root, "tmp", "pids")
    }

    attr_accessor :service_name, :pid_dir

    def initialize
      DEFAULTS.each do |key, value|
        send("#{key}=", value)
      end
    end
  end

  class << self
    delegate :start, :stop, :running?, to: :instance

    def config
      yield instance.config
    end
  end

  attr_reader :config

  def initialize
    @config = Config.new
  end

  def start
    run("start")
  end

  def stop
    run("stop")
  end

  def running?
    pid_file_path = Daemons::PidFile.find_files(@config.pid_dir, @config.service_name).first
    return false unless pid_file_path.present?

    pid_file = Daemons::PidFile.existing(pid_file_path)
    Daemons::Pid.running?(pid_file.pid)
  end

  private

  def run(command)
    system "bundle exec #{SERVICE_PATH} #{command} -d #{@config.pid_dir} -n #{@config.service_name}"
  end
end
