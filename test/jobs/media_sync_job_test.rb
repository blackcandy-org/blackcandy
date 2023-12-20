# frozen_string_literal: true

require "test_helper"

class MediaSyncJobTest < ActiveJob::TestCase
  test "sync media" do
    mock = Minitest::Mock.new
    mock.expect(:call, true, [])

    MediaSyncJob.perform_later

    Media.stub(:sync_all, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end
end
