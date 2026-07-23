# frozen_string_literal: true

require "test_helper"

class BlackCandy::VersionTest < ActiveSupport::TestCase
  test "should get version string and link" do
    with_env("COMMIT_HASH" => "abcdef1234567890") do
      BlackCandy::Version.stub(:edge_release?, false) do
        assert_equal "abcdef1234567890", BlackCandy::Version.commit_hash
        assert_match(/^v\d+\.\d+\.\d+$/, BlackCandy::Version.to_s)
        assert_match(/github\.com\/blackcandy-org\/blackcandy\/releases\/tag\/v\.*/, BlackCandy::Version.link)
      end
    end
  end

  test "should get edge version string and link when it is edge release" do
    with_env("COMMIT_HASH" => "abcdef1234567890") do
      BlackCandy::Version.stub(:edge_release?, true) do
        assert_equal "version: edge(abcdef1)", BlackCandy::Version.to_s
        assert_match(/github\.com\/blackcandy-org\/blackcandy\/commit\/abcdef1234567890/, BlackCandy::Version.link)
      end
    end
  end
end
