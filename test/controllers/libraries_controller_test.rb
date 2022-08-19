# frozen_string_literal: true

require "test_helper"

class LibrariesControllerTest < ActionDispatch::IntegrationTest
  test "should show library" do
    login
    get library_path

    assert_response :success
  end
end
