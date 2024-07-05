# frozen_string_literal: true

class MediaSyncAllJob < MediaSyncJob
  def perform(dir = Setting.media_path)
    file_paths = MediaFile.file_paths(dir)
    parallel_processor_count = self.class.config.parallel_processor_count
    file_md5_hashes = Parallel.map(file_paths, in_processes: parallel_processor_count) do |file_path|
      MediaFile.get_md5_hash(file_path, with_mtime: true)
    end

    existing_songs = Song.where(md5_hash: file_md5_hashes)
    added_file_paths = file_paths - existing_songs.pluck(:file_path)

    return if added_file_paths.blank?

    grouped_file_paths = (parallel_processor_count > 0) ? added_file_paths.in_groups(parallel_processor_count, false).compact_blank : [added_file_paths]

    added_song_hashes = Parallel.map(grouped_file_paths, in_processes: parallel_processor_count) do |paths|
      Media.sync(:added, paths)
    end.flatten.compact

    Media.clean_up(added_song_hashes + existing_songs.pluck(:md5_hash))
  end

  private

  def after_sync(_)
    Media.instance.broadcast_render_to "media_sync", partial: "media_syncing/syncing", locals: {syncing: false}
    super(fetch_external_metadata: true)
  end
end
