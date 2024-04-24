# frozen_string_literal: true

require "puma/plugin"

Puma::Plugin.create do
  def start(launcher)
    launcher.events.on_booted { MediaListener.start if Setting.enable_media_listener? }
    launcher.events.on_stopped { MediaListener.stop }
    launcher.events.on_restart { MediaListener.stop }
  end
end
