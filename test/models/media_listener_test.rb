# frozen_string_literal: true

require "test_helper"

class MediaListenerTest < ActiveSupport::TestCase
  teardown do
    MediaListener.stop
  end

  test "start listening" do
    MediaListener.start

    assert MediaListener.running?
  end

  test "stop listening" do
    MediaListener.start
    MediaListener.stop

    assert_not MediaListener.running?
  end
end
