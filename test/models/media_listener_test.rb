# frozen_string_literal: true

require "test_helper"

class MediaListenerTest < ActiveSupport::TestCase
  test "running listener" do
    assert_not MediaListener.running?

    MediaListener.start
    assert MediaListener.running?

    MediaListener.stop
    assert_not MediaListener.running?
  end
end
