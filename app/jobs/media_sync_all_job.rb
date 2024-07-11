# frozen_string_literal: true

class MediaSyncAllJob < MediaSyncJob
  def perform(dir = Setting.media_path)
    file_paths = MediaFile.file_paths(dir)
    file_md5_hashes = Parallel.map(file_paths, in_processes: self.class.parallel_processor_count) do |file_path|
      MediaFile.get_md5_hash(file_path, with_mtime: true)
    end

    existing_songs = Song.where(md5_hash: file_md5_hashes)
    added_file_paths = file_paths - existing_songs.pluck(:file_path)
    added_song_hashes = added_file_paths.blank? ? [] : parallel_sync(:added, added_file_paths).flatten.compact

    Media.clean_up(added_song_hashes + existing_songs.pluck(:md5_hash))
  end

  private

  def after_sync(_)
    Media.instance.broadcast_render_to "media_sync", partial: "media_syncing/syncing", locals: {syncing: false}
    super(fetch_external_metadata: true)
  end
end
