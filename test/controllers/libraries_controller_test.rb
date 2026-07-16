# frozen_string_literal: true

require "test_helper"

class LibrariesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    login
    get library_url

    assert_response :success
  end
end
