# frozen_string_literal: true

task listen: :environment do
  listener = Listen.to(File.expand_path(Setting.media_path)) do |modified, added, removed|
    MediaSyncJob.perform_later
  end

  listener.start

  sleep
end
