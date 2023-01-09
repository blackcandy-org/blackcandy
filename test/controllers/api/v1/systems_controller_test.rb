# frozen_string_literal: true

require "test_helper"

class Api::V1::SystemsControllerTest < ActionDispatch::IntegrationTest
  test "should get system version" do
    get api_v1_system_url, as: :json
    response = @response.parsed_body["version"]

    assert_response :success
    assert_equal BlackCandy::Version::MAJOR, response["major"]
    assert_equal BlackCandy::Version::MINOR, response["minor"]
    assert_equal BlackCandy::Version::PATCH, response["patch"]
    assert_equal BlackCandy::Version::PRE, response["pre"]
  end
end
