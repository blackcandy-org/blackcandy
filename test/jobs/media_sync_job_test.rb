# frozen_string_literal: true

require "test_helper"

class MediaSyncJobTest < ActiveJob::TestCase
  test "sync all media" do
    mock = Minitest::Mock.new
    mock.expect(:call, true, [])

    MediaSyncJob.perform_later

    Media.stub(:sync_all, mock) do
      perform_enqueued_jobs
      mock.verify
    end
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
end
