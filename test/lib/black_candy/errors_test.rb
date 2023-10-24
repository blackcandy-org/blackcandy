# frozen_string_literal: true

require "test_helper"

class BlackCandy::ErrorsTest < ActiveSupport::TestCase
  test "should get info from forbidden error" do
    error = BlackCandy::Forbidden.new

    assert_equal "Forbidden", error.type
    assert_not_empty error.message
  end

  test "should get info from invalid credential error" do
    error = BlackCandy::InvalidCredential.new

    assert_equal "InvalidCredential", error.type
    assert_not_empty error.message
  end

  test "should get info from duplicate playlist song error" do
    error = BlackCandy::DuplicatePlaylistSong.new

    assert_equal "DuplicatePlaylistSong", error.type
    assert_not_empty error.message
  end
end
