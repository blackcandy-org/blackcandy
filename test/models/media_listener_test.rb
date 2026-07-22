# frozen_string_literal: true

require "test_helper"

class MediaListenerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class FakeListener
    attr_reader :changes_handler

    def to(*, **, &changes_handler)
      @changes_handler = changes_handler
      self
    end

    def start = nil
    def stop = nil
  end

  teardown do
    MediaListener.stop
  end

  test "running listener" do
    assert_not MediaListener.running?

    MediaListener.start
    assert MediaListener.running?

    MediaListener.stop
    assert_not MediaListener.running?
  end

  test "enqueue MediaSyncJob when watched files changed" do
    fake_listener = FakeListener.new

    Listen.stub(:to, fake_listener.method(:to)) do
      MediaListener.start

      assert_enqueued_with(job: MediaSyncJob, args: [ :modified, [ "modified.mp3" ] ]) do
        fake_listener.changes_handler.call([ "modified.mp3" ], [], [])
      end

      assert_enqueued_with(job: MediaSyncJob, args: [ :added, [ "added.mp3" ] ]) do
        fake_listener.changes_handler.call([], [ "added.mp3" ], [])
      end

      assert_enqueued_with(job: MediaSyncJob, args: [ :removed, [ "removed.mp3" ] ]) do
        fake_listener.changes_handler.call([], [], [ "removed.mp3" ])
      end
    end
  end

  test "not enqueue MediaSyncJob when no files changed" do
    fake_listener = FakeListener.new

    Listen.stub(:to, fake_listener.method(:to)) do
      MediaListener.start

      assert_no_enqueued_jobs only: MediaSyncJob do
        fake_listener.changes_handler.call([], [], [])
      end
    end
  end
end
