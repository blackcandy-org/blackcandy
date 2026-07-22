# frozen_string_literal: true

require "puma/plugin"

Puma::Plugin.create do
  def start(launcher)
    launcher.events.after_booted { MediaListener.start if Setting.enable_media_listener? }
    launcher.events.after_stopped { MediaListener.stop }
    launcher.events.before_restart { MediaListener.stop }
  end
end
