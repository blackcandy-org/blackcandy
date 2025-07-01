# frozen_string_literal: true

require "test_helper"

class BlackCandy::VersionTest < ActiveSupport::TestCase
  test "should get version string and link" do
    with_env("COMMIT_HASH" => "abcdef1234567890") do
      assert_equal "abcdef1234567890", BlackCandy::Version.commit_hash
      assert_match(/^v\d+\.\d+\.\d+$/, BlackCandy::Version.to_s)
      assert_match(/github\.com\/blackcandy-org\/blackcandy\/releases\/tag\/v\.*/, BlackCandy::Version.link)
    end
  end

  test "should get edge version string and link when it is edge release" do
    file_path = Rails.root.join(".is-edge-release.txt")
    FileUtils.touch(file_path)

    with_env("COMMIT_HASH" => "abcdef1234567890") do
      assert_equal "version: edge(abcdef1)", BlackCandy::Version.to_s
      assert_match(/github\.com\/blackcandy-org\/blackcandy\/commit\/abcdef1234567890/, BlackCandy::Version.link)
    end
  ensure
    FileUtils.remove_file(file_path)
  end
end
