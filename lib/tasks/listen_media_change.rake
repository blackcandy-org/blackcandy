# frozen_string_literal: true

task listen_media_changes: :environment do
  supported_formates = MediaFile::SUPPORTED_FORMATS.map { |formate| %r{\.#{formate}$} }

  listener = Listen.to(File.expand_path(Setting.media_path), only: supported_formates) do |modified, added, removed|
    MediaSyncJob.perform_later(:modified, modified) if modified.present?
    MediaSyncJob.perform_later(:added, added) if added.present?
    MediaSyncJob.perform_later(:removed, removed) if removed.present?
  end

  listener.start

  sleep
end
