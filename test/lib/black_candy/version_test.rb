# frozen_string_literal: true

require "test_helper"

class BlackCandy::VersionTest < ActiveSupport::TestCase
  test "should get version string" do
    assert_not_empty BlackCandy::Version.to_s
    assert_not_equal "Edge", BlackCandy::Version.to_s
  end

  test "should get edge version string when it is edge release" do
    file_path = Rails.root.join(".is-edge-release.txt")
    FileUtils.touch(file_path)

    assert_equal "Edge", BlackCandy::Version.to_s
  ensure
    FileUtils.remove_file(file_path)
  end
end
