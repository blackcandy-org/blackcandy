Rails.application.config.after_initialize do
  MediaListener.start if Setting.enable_media_listener? && !MediaListener.running?
end

at_exit do
  MediaListener.stop if MediaListener.running?
end
