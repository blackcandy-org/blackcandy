# frozen_string_literal: true

require "test_helper"

class MediaSyncJobTest < ActiveJob::TestCase
  setup do
    clear_media_data
  end

  test "sync added media" do
    file_paths = [fixtures_file_path("artist1_album1.flac")]
    mock = Minitest::Mock.new

    mock.expect(:call, true, [:added, file_paths])

    MediaSyncJob.perform_later(:added, file_paths)

    Media.stub(:sync, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end

  test "sync removed media" do
    file_paths = [fixtures_file_path("artist1_album1.flac")]
    mock = Minitest::Mock.new

    mock.expect(:call, true, [:removed, file_paths])

    MediaSyncJob.perform_later(:removed, file_paths)

    Media.stub(:sync, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end

  test "sync modified media" do
    file_paths = [fixtures_file_path("artist1_album1.flac")]
    mock = Minitest::Mock.new

    mock.expect(:call, true, [:modified, file_paths])

    MediaSyncJob.perform_later(:modified, file_paths)

    Media.stub(:sync, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end

  test "should change syncing status" do
    assert_not Media.syncing?

    mock = Minitest::Mock.new
    mock.expect(:call, true, [true])
    mock.expect(:call, true, [false])

    MediaSyncJob.perform_later(:added, [fixtures_file_path("artist1_album1.flac")])

    Media.stub(:syncing=, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end

  test "should fetch external metadata unless sync type is removed" do
    Setting.update(discogs_token: "fake_token")

    assert_enqueued_jobs 2, only: AttachCoverImageFromDiscogsJob do
      MediaSyncJob.perform_now(:added, [fixtures_file_path("artist1_album1.flac"), fixtures_file_path("artist2_album3.wav")])
    end

    assert_no_enqueued_jobs only: AttachCoverImageFromDiscogsJob do
      MediaSyncJob.perform_now(:removed, [fixtures_file_path("artist1_album1.flac")])
    end
  end
end
