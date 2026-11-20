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

    assert Media.syncing?
  end

  test "should full sync media" do
    login users(:admin)

    Media.stub(:syncing?, false) do
      assert_enqueued_with(job: MediaSyncAllJob, args: [ { full: true } ]) do
        post media_syncing_url(full: true)
      end
    end
  end

  test "should show syncing button when the media is syncing" do
    login users(:admin)

    Media.stub(:syncing?, true) do
      get media_syncing_url
    end

    assert_response :success
    assert_includes response.body, I18n.t("button.syncing")
    assert_not_includes response.body, I18n.t("notice.sync_completed")
  end

  test "should show sync completed notice when the media is not syncing" do
    login users(:admin)

    Media.stub(:syncing?, false) do
      get media_syncing_url
    end

    assert_response :success
    assert_includes response.body, I18n.t("notice.sync_completed")
  end

  test "should only admin can get media syncing status" do
    login

    get media_syncing_url
    assert_response :forbidden
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
