# frozen_string_literal: true

require "test_helper"

class MediaSyncJobTest < ActiveJob::TestCase
  test "sync media" do
    mock = Minitest::Mock.new
    mock.expect(:call, true, [:all, []])

    Setting.update(media_path: Rails.root.join("test/fixtures/files"))

    MediaSyncJob.perform_later

    Media.stub(:sync, mock) do
      perform_enqueued_jobs
      mock.verify
    end
  end
end
