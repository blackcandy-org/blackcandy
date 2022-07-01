# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    login
    get root_url

    assert_redirected_to albums_url
  end
end
