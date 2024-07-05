# frozen_string_literal: true

require "test_helper"

class MediaSyncingControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should sync media" do
    login users(:admin)

    Media.stub(:syncing?, false) do
      assert_enqueued_with(job: MediaSyncAllJob) do
        post media_syncing_url
      end
    end
  end

  test "should only admin can sync media" do
    login

    post media_syncing_url
    assert_response :forbidden
  end

  test "should not sync media when the media is syncing" do
    login users(:admin)

    Media.stub(:syncing?, true) do
      assert_no_enqueued_jobs do
        post media_syncing_url
      end
    end
  end
end
