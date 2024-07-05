# frozen_string_literal: true

require "test_helper"

class MediaTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  setup do
    clear_media_data
  end

  test "should get syncing status" do
    assert_not Media.syncing?
  end

  test "should change syncing status" do
    Media.syncing = true
    assert Media.syncing?
  end

  test "should always get same instance" do
    assert_equal Media.instance.object_id, Media.instance.object_id
  end

  test "should add records and create associations when selectively added files" do
    clear_media_data

    Media.sync(:added, [file_fixture("artist1_album2.mp3"), file_fixture("artist1_album1.flac")])

    assert_equal 1, Artist.count
    assert_equal 2, Album.count
    assert_equal 2, Song.count

    Media.sync(:added, [file_fixture("artist1_album1.m4a")])

    assert_equal Song.where(name: %w[flac_sample m4a_sample]).ids.sort, Album.find_by(name: "album1").songs.ids.sort
    assert_equal Song.where(name: %w[mp3_sample flac_sample m4a_sample]).ids.sort, Artist.find_by(name: "artist1").songs.ids.sort
  end

  test "should remove records when selectively removed files" do
    create_tmp_dir(from: Setting.media_path) do |tmp_dir|
      Media.sync(:added, MediaFile.file_paths(tmp_dir))

      selected_files = [File.join(tmp_dir, "artist1_album2.mp3"), File.join(tmp_dir, "artist1_album1.flac")]
      selected_files.each { |file_path| File.delete file_path }
      Media.sync(:removed, selected_files)

      assert_nil Song.find_by(name: "mp3_sample")
      assert_nil Song.find_by(name: "flac_sample")
      assert_nil Album.find_by(name: "album2")

      selected_files = [File.join(tmp_dir, "artist1_album1.m4a"), File.join(tmp_dir, "various_artists.mp3")]
      selected_files.each { |file_path| File.delete file_path }
      Media.sync(:removed, selected_files)

      assert_nil Song.find_by(name: "various_artists_sample")
      assert_nil Song.find_by(name: "m4a_sample")
      assert_nil Album.find_by(name: "album1")
      assert_nil Artist.find_by(name: "artist1")
    end
  end

  test "should change associations when selectively modified album info on file" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))

    stub_file_metadata(file_fixture("artist1_album2.mp3"), album_name: "album1") do
      Media.sync(:modified, [file_fixture("artist1_album2.mp3")])

      album1_songs_ids = Song.where(name: %w[flac_sample m4a_sample mp3_sample]).ids.sort

      assert_equal Album.where(name: "album1").ids.sort, Artist.find_by(name: "artist1").albums.ids.sort
      assert_equal album1_songs_ids, Album.find_by(name: "album1").songs.ids.sort
    end
  end

  test "should change associations when selectively modified artist info on file" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))

    stub_file_metadata(file_fixture("artist1_album2.mp3"), artist_name: "artist2", albumartist_name: "artist2") do
      Media.sync(:modified, [file_fixture("artist1_album2.mp3")])

      artist2_songs_ids = Song.where(
        name: %w[mp3_sample ogg_sample wav_sample opus_sample oga_sample wma_sample]
      ).ids.sort

      assert_equal Album.where(name: %w[album2 album3]).ids.sort, Artist.find_by(name: "artist2").albums.ids.sort
      assert_equal artist2_songs_ids, Artist.find_by(name: "artist2").songs.ids.sort
    end
  end

  test "should change song attribute when selectively modified song info on file" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))

    stub_file_metadata(file_fixture("artist1_album2.mp3"), tracknum: 2) do
      assert_changes -> { Song.find_by(name: "mp3_sample").tracknum }, from: 1, to: 2 do
        Media.sync(:modified, [file_fixture("artist1_album2.mp3")])
      end
    end
  end

  test "should set album attributes after synced" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))

    album1 = Album.find_by(name: "album1")
    album2 = Album.find_by(name: "album2")
    album3 = Album.find_by(name: "album3")
    album4 = Album.find_by(name: "album4")

    assert_equal "Rock", album1.genre
    assert_equal 1984, album1.year

    assert_equal "Rock", album2.genre
    assert_equal 1984, album2.year

    assert_equal "Rock", album3.genre
    assert_equal 1984, album3.year

    assert_nil album4.genre
    assert_nil album4.year
  end

  test "should clean up no content albums and artists" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))

    Song.where(name: %w[flac_sample mp3_sample m4a_sample various_artists_sample]).destroy_all

    Media.clean_up

    assert_nil Artist.find_by(name: "artist1")
    assert_nil Album.find_by(name: "album1")
    assert_nil Album.find_by(name: "album2")
  end

  test "should clean up no content albums and artists when specific files excluded" do
    Media.sync(:added, [file_fixture("artist1_album2.mp3"), file_fixture("artist1_album1.flac"), file_fixture("artist2_album3.ogg")])
    assert_equal 2, Artist.count

    Media.clean_up([MediaFile.get_md5_hash(file_fixture("artist2_album3.ogg"), with_mtime: true)])
    assert_equal 1, Artist.count
    assert_nil Artist.find_by(name: "artist1")
    assert_nil Album.find_by(name: "album1")
    assert_nil Album.find_by(name: "album2")
  end

  test "should fetch external metadata" do
    Media.sync(:added, MediaFile.file_paths(Setting.media_path))
    Setting.update(discogs_token: "fake_token")

    jobs_count = Album.lack_metadata.count + Artist.lack_metadata.count

    assert jobs_count.positive?

    assert_enqueued_jobs jobs_count, only: AttachCoverImageFromDiscogsJob do
      Media.fetch_external_metadata
    end
  end
end
