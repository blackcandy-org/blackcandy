# frozen_string_literal: true

require "test_helper"

class MediaSyncJobTest < ActiveJob::TestCase
  setup do
    flush_redis
  end

  test "sync media" do
    mock = MiniTest::Mock.new
    mock.expect(:call, true, [:all, []])

    Setting.update(media_path: Rails.root.join("test/fixtures/files"))
    assert_not Media.syncing?

    MediaSyncJob.perform_later
    assert Media.syncing?

    Media.stub(:sync, mock) do
      perform_enqueued_jobs
      mock.verify
    end

    assert_not Media.syncing?
  end
end
